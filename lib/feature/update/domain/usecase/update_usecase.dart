import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_service/api_client.dart';
import '../../../../core/network/api_service/api_endpoints.dart';
import '../../data/model/update_model.dart';

class UpdateUseCase {
  Future<List<UpdateProjectModel>> fetchProjects(ApiClient apiClient) async {
    final response = await apiClient.get(ProjectEndpoints.getAll);
    final rawItems = _extractList(response.data, preferredListKey: 'projects');
    return rawItems.map(UpdateProjectModel.fromJson).toList();
  }

  Future<List<UpdateModel>> fetchProjectUpdates({
    required ApiClient apiClient,
    required String projectId,
  }) async {
    final response = await apiClient.get(
      UpdateEndpoints.getByProject(projectId),
    );
    final rawItems = _extractList(response.data, preferredListKey: 'updates');
    return rawItems.map(UpdateModel.fromJson).toList();
  }

  Future<UpdateModel> toggleLike({
    required ApiClient apiClient,
    required String updateId,
  }) async {
    final response = await apiClient.patch(UpdateEndpoints.like(updateId));
    final data = _extractMap(response.data);
    return UpdateModel.fromJson(data);
  }

  Future<int> shareUpdate({
    required ApiClient apiClient,
    required String updateId,
  }) async {
    final response = await apiClient.post(UpdateEndpoints.share(updateId));
    final data = _extractMap(response.data);
    final count = data['shareCount'];
    if (count is int) return count;
    if (count is double) return count.round();
    if (count is String) {
      return int.tryParse(count.trim()) ?? 0;
    }
    return 0;
  }

  Future<List<UpdateCommentModel>> getComments({
    required ApiClient apiClient,
    required String updateId,
  }) async {
    final response = await apiClient.get(UpdateEndpoints.getComments(updateId));
    final rawItems = _extractCommentList(response.data);
    return rawItems
        .map((item) => _normalizeCommentMap(item, updateId: updateId))
        .map(UpdateCommentModel.fromJson)
        .toList();
  }

  Future<UpdateCommentModel> addComment({
    required ApiClient apiClient,
    required String updateId,
    required String comment,
  }) async {
    final response = await apiClient.post(
      UpdateEndpoints.addComment(updateId),
      data: {
        // Keep both keys for compatibility across backend validators.
        'comment': comment,
        'text': comment,
      },
    );
    final data = _extractCreatedCommentMap(response.data);
    final normalized = _normalizeCommentMap(
      data,
      updateId: updateId,
      fallbackComment: comment,
    );
    return UpdateCommentModel.fromJson(normalized);
  }

  Future<UpdateModel> createUpdate({
    required ApiClient apiClient,
    required String projectId,
    required String description,
    required List<File> images,
  }) async {
    final files = <MultipartFile>[];
    for (final image in images) {
      files.add(await MultipartFile.fromFile(image.path));
    }

    final payload = FormData.fromMap({
      'projectId': projectId,
      'description': description,
      'images': files,
    });

    final response = await apiClient.post(
      UpdateEndpoints.create,
      data: payload,
    );
    final data = _extractMap(response.data);
    return UpdateModel.fromJson(data);
  }

  List<String> buildCategoryFilters(List<UpdateModel> updates) {
    final uniqueCategories = <String>[];
    for (final item in updates) {
      final category = item.category.trim();
      if (category.isEmpty) continue;

      final exists = uniqueCategories.any(
        (e) => e.toLowerCase() == category.toLowerCase(),
      );
      if (!exists) {
        uniqueCategories.add(category);
      }
    }

    if (uniqueCategories.length > 1) {
      return ['All', ...uniqueCategories];
    }
    return uniqueCategories;
  }

  String resolveSelectedCategory({
    required List<String> categoryFilters,
    required String currentSelected,
  }) {
    if (categoryFilters.isEmpty) {
      return 'All';
    }

    final index = categoryFilters.indexWhere(
      (e) => e.toLowerCase() == currentSelected.toLowerCase(),
    );
    if (index >= 0) {
      return categoryFilters[index];
    }
    return categoryFilters.first;
  }

  List<UpdateModel> filterUpdates({
    required List<UpdateModel> updates,
    required String selectedCategory,
  }) {
    if (selectedCategory.toLowerCase() == 'all') {
      return updates;
    }

    final selected = selectedCategory.trim().toLowerCase();
    return updates
        .where((e) => e.category.trim().toLowerCase() == selected)
        .toList();
  }

  bool shouldShowCategoryDropdown(List<String> categoryFilters) {
    return categoryFilters.length > 1;
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

  List<Map<String, dynamic>> _extractCommentList(dynamic payload) {
    final direct = _extractList(payload, preferredListKey: 'comments');
    if (direct.isNotEmpty) return direct;

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final fromUpdate = data['update'];
        if (fromUpdate is Map<String, dynamic>) {
          final comments = fromUpdate['comments'];
          if (comments is List) {
            return comments.whereType<Map<String, dynamic>>().toList();
          }
        }
      }
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractCreatedCommentMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final comment = data['comment'];
        if (comment is Map<String, dynamic>) return comment;
      }

      final comment = payload['comment'];
      if (comment is Map<String, dynamic>) return comment;
    }

    return _extractMap(payload);
  }

  Map<String, dynamic> _normalizeCommentMap(
    Map<String, dynamic> raw, {
    required String updateId,
    String fallbackComment = '',
  }) {
    final normalized = Map<String, dynamic>.from(raw);

    final rawUpdate = normalized['update'];
    final rawUpdateId = normalized['updateId'];
    final hasUpdate =
        (rawUpdate != null && rawUpdate.toString().trim().isNotEmpty) ||
        (rawUpdateId != null && rawUpdateId.toString().trim().isNotEmpty);
    if (!hasUpdate) {
      normalized['update'] = updateId;
    }

    final rawComment = normalized['comment'];
    final rawText = normalized['text'];
    final hasCommentText =
        (rawComment != null && rawComment.toString().trim().isNotEmpty) ||
        (rawText != null && rawText.toString().trim().isNotEmpty);
    if (!hasCommentText && fallbackComment.trim().isNotEmpty) {
      normalized['comment'] = fallbackComment.trim();
    }

    return normalized;
  }
}
