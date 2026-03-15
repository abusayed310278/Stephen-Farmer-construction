import 'dart:io';

import 'package:dio/dio.dart';
import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';

import '../../domain/entities/document_project_entity.dart';
import '../../domain/repository/document_repository.dart';
import '../model/document_project_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({
    required ApiClient apiClient,
    this.useMockData = false,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final bool useMockData;

  @override
  Future<List<DocumentProjectEntity>> fetchProjects() async {
    if (useMockData) {
      return DocumentProjectModel.dummyData;
    }

    try {
      final projectsResponse = await _apiClient.get(ProjectEndpoints.getAll);
      final projectRows = _extractList(
        projectsResponse.data,
        preferredListKey: 'projects',
      );

      if (projectRows.isEmpty) {
        return const <DocumentProjectEntity>[];
      }

      final projects = projectRows
          .map(DocumentProjectModel.fromProjectJson)
          .where((project) => project.projectId.trim().isNotEmpty)
          .toList(growable: false);

      final enriched = await Future.wait(
        projects.map(_enrichProjectWithDocuments),
      );

      return enriched;
    } catch (e) {
      throw Exception('Failed to fetch document projects: $e');
    }
  }

  @override
  Future<void> uploadDocument({
    required String projectId,
    required File document,
    required String title,
    required String category,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedCategory = category.trim();
    if (trimmedTitle.isEmpty || trimmedCategory.isEmpty) {
      throw Exception('Document title and category are required.');
    }

    final payload = FormData.fromMap({
      'projectId': projectId,
      'document': await MultipartFile.fromFile(document.path),
      'title': trimmedTitle,
      'category': trimmedCategory,
    });

    await _apiClient.post(DocumentEndpoints.create, data: payload);
  }

  Future<DocumentProjectEntity> _enrichProjectWithDocuments(
    DocumentProjectModel project,
  ) async {
    final response = await _apiClient.get(
      DocumentEndpoints.getByProject(project.projectId),
    );

    final categoryRows = _extractCategoryRows(response.data);
    final documentRows = _extractDocumentRows(response.data);

    final categories = categoryRows.isNotEmpty
        ? categoryRows
              .map(DocumentCategoryModel.fromJson)
              .toList(growable: false)
        : DocumentProjectModel.summarizeCategories(documentRows);
    final recents = documentRows
        .map(RecentDocumentModel.fromJson)
        .toList(growable: false);

    return project.copyWithDocuments(
      categories: categories,
      recentDocuments: recents,
    );
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    dynamic source = payload;

    if (source is Map<String, dynamic>) {
      source = source['data'] ?? source;
    }

    if (source is Map<String, dynamic>) {
      return source;
    }

    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractList(
    dynamic payload, {
    String preferredListKey = 'items',
  }) {
    dynamic source = payload;

    if (source is Map<String, dynamic>) {
      source =
          source['data'] ??
          source[preferredListKey] ??
          source['items'] ??
          source['results'] ??
          source;

      if (source is Map<String, dynamic>) {
        source =
            source[preferredListKey] ??
            source['items'] ??
            source['results'] ??
            source['data'] ??
            [];
      }
    }

    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractCategoryRows(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directData = payload['data'];
      if (directData is Map<String, dynamic>) {
        final fromCounts = _extractCategoryRowsFromCounts(directData['counts']);
        if (fromCounts.isNotEmpty) {
          return fromCounts;
        }

        final rows =
            directData['categories'] ??
            directData['types'] ??
            directData['documentTypes'] ??
            directData['summary'];
        if (rows is List) {
          return rows.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    if (payload is List) {
      return <Map<String, dynamic>>[];
    }

    final mapPayload = _extractMap(payload);
    final fromCounts = _extractCategoryRowsFromCounts(mapPayload['counts']);
    if (fromCounts.isNotEmpty) {
      return fromCounts;
    }

    final rows =
        mapPayload['categories'] ??
        mapPayload['types'] ??
        mapPayload['documentTypes'] ??
        mapPayload['summary'];

    if (rows is List) {
      return rows.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _extractDocumentRows(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directData = payload['data'];
      if (directData is List) {
        return directData.whereType<Map<String, dynamic>>().toList();
      }
      if (directData is Map<String, dynamic>) {
        final categoryMappedRows = _flattenCategoryDocumentMap(
          directData['documents'],
        );
        if (categoryMappedRows.isNotEmpty) {
          return categoryMappedRows;
        }

        final nestedList =
            directData['documents'] ??
            directData['items'] ??
            directData['results'] ??
            directData['data'];
        if (nestedList is List) {
          return nestedList.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }

    final mapPayload = _extractMap(payload);
    final source =
        mapPayload['documents'] ??
        mapPayload['items'] ??
        mapPayload['results'] ??
        mapPayload['recentDocuments'] ??
        mapPayload['data'];

    final flattened = _flattenCategoryDocumentMap(source);
    if (flattened.isNotEmpty) {
      return flattened;
    }

    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList();
    }

    if (source is Map<String, dynamic>) {
      final inner =
          source['documents'] ??
          source['items'] ??
          source['results'] ??
          source['data'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _flattenCategoryDocumentMap(dynamic source) {
    if (source is! Map<String, dynamic>) return const <Map<String, dynamic>>[];

    final rows = <Map<String, dynamic>>[];
    for (final entry in source.entries) {
      final category = entry.key;
      final value = entry.value;
      if (value is! List) continue;

      for (final item in value) {
        if (item is! Map<String, dynamic>) continue;
        final normalized = Map<String, dynamic>.from(item);
        if ((normalized['category']?.toString().trim().isEmpty ?? true)) {
          normalized['category'] = category;
        }
        rows.add(normalized);
      }
    }
    return rows;
  }

  List<Map<String, dynamic>> _extractCategoryRowsFromCounts(dynamic source) {
    if (source is! Map<String, dynamic>) return const <Map<String, dynamic>>[];

    final rows = <Map<String, dynamic>>[];
    for (final entry in source.entries) {
      final key = entry.key.toString().trim();
      if (key.isEmpty) continue;

      final rawCount = entry.value;
      final count = rawCount is num ? rawCount.toInt() : 0;
      rows.add(<String, dynamic>{
        'title': _capitalize(key),
        'type': key,
        'fileCount': count,
      });
    }
    return rows;
  }

  String _capitalize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return value;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}
