import '../../domain/entities/document_project_entity.dart';

class DocumentCategoryModel extends DocumentCategoryEntity {
  const DocumentCategoryModel({
    required super.title,
    required super.fileCount,
    required super.type,
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      title: _readString(json, ['title', 'name'], fallback: 'Category'),
      fileCount: _readInt(json, ['fileCount', 'count'], fallback: 0),
      type: _readString(json, ['type', 'key'], fallback: 'default'),
    );
  }
}

class RecentDocumentModel extends RecentDocumentEntity {
  const RecentDocumentModel({
    required super.id,
    required super.title,
    required super.category,
    required super.dateLabel,
    super.fileUrl,
    super.mimeType,
  });

  factory RecentDocumentModel.fromJson(Map<String, dynamic> json) {
    final dateSource = _readString(json, [
      'dateLabel',
      'date',
      'createdAt',
      'updatedAt',
      'uploadedAt',
    ]);

    final nestedDocument = json['document'];
    final nestedUrl = nestedDocument is Map<String, dynamic>
        ? _readString(nestedDocument, ['url', 'secure_url', 'path'])
        : '';
    final directUrl = _readString(json, ['url', 'fileUrl', 'documentUrl']);
    final resolvedUrl = directUrl.trim().isNotEmpty
        ? directUrl.trim()
        : nestedUrl.trim();

    return RecentDocumentModel(
      id: _readString(json, ['_id', 'id', 'documentId']),
      title: _readString(json, [
        'title',
        'name',
        'originalName',
      ], fallback: 'Untitled Document'),
      category: _readString(json, ['category', 'type'], fallback: 'General'),
      dateLabel: _formatDateLabel(dateSource),
      fileUrl: resolvedUrl.isEmpty ? null : resolvedUrl,
      mimeType: _readMimeType(json),
    );
  }
}

class DocumentProjectModel extends DocumentProjectEntity {
  const DocumentProjectModel({
    required super.projectId,
    required super.projectName,
    required super.projectAddress,
    super.thumbnailUrl,
    required super.categories,
    required super.recentDocuments,
  });

  factory DocumentProjectModel.fromProjectJson(Map<String, dynamic> json) {
    final thumb = _readProjectThumbnail(json);
    return DocumentProjectModel(
      projectId: _readString(json, ['_id', 'id', 'projectId']),
      projectName: _readString(json, [
        'projectName',
        'name',
        'title',
      ], fallback: 'Untitled Project'),
      projectAddress: _readString(json, [
        'projectAddress',
        'address',
        'location',
      ], fallback: 'N/A'),
      thumbnailUrl: thumb.isEmpty ? null : thumb,
      categories: const <DocumentCategoryEntity>[],
      recentDocuments: const <RecentDocumentEntity>[],
    );
  }

  factory DocumentProjectModel.fromApi({
    required Map<String, dynamic> projectJson,
    required List<Map<String, dynamic>> categoryRows,
    required List<Map<String, dynamic>> documentRows,
  }) {
    final thumb = _readProjectThumbnail(projectJson);
    final categories = categoryRows
        .map(DocumentCategoryModel.fromJson)
        .toList(growable: false);

    final recentDocuments = documentRows
        .map(RecentDocumentModel.fromJson)
        .toList(growable: false);

    return DocumentProjectModel(
      projectId: _readString(projectJson, ['_id', 'id', 'projectId']),
      projectName: _readString(projectJson, [
        'projectName',
        'name',
        'title',
      ], fallback: 'Untitled Project'),
      projectAddress: _readString(projectJson, [
        'projectAddress',
        'address',
        'location',
      ], fallback: 'N/A'),
      thumbnailUrl: thumb.isEmpty ? null : thumb,
      categories: categories,
      recentDocuments: recentDocuments,
    );
  }

  DocumentProjectModel copyWithDocuments({
    required List<DocumentCategoryEntity> categories,
    required List<RecentDocumentEntity> recentDocuments,
  }) {
    return DocumentProjectModel(
      projectId: projectId,
      projectName: projectName,
      projectAddress: projectAddress,
      thumbnailUrl: thumbnailUrl,
      categories: categories,
      recentDocuments: recentDocuments,
    );
  }

  static List<DocumentCategoryModel> summarizeCategories(
    List<Map<String, dynamic>> documents,
  ) {
    final counters = <String, int>{};

    for (final row in documents) {
      final category = _readString(row, [
        'category',
        'type',
      ], fallback: 'General');
      final normalized = category.trim();
      if (normalized.isEmpty) continue;
      counters[normalized] = (counters[normalized] ?? 0) + 1;
    }

    final normalizedByType = {
      'drawings': 0,
      'invoices': 0,
      'reports': 0,
      'contracts': 0,
    };

    for (final entry in counters.entries) {
      final key = _normalizeType(entry.key);
      normalizedByType[key] = (normalizedByType[key] ?? 0) + entry.value;
    }

    return [
      DocumentCategoryModel(
        title: 'Drawings',
        fileCount: normalizedByType['drawings'] ?? 0,
        type: 'drawings',
      ),
      DocumentCategoryModel(
        title: 'Invoices',
        fileCount: normalizedByType['invoices'] ?? 0,
        type: 'invoices',
      ),
      DocumentCategoryModel(
        title: 'Reports',
        fileCount: normalizedByType['reports'] ?? 0,
        type: 'reports',
      ),
      DocumentCategoryModel(
        title: 'Contracts',
        fileCount: normalizedByType['contracts'] ?? 0,
        type: 'contracts',
      ),
    ];
  }

  static List<DocumentProjectModel> dummyData = [
    DocumentProjectModel(
      projectId: 'project-1',
      projectName: 'Riverside Apartment Renovation',
      projectAddress: '42 Harbor View Drive, Apt 12B',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&auto=format&fit=crop',
      categories: const [
        DocumentCategoryModel(
          title: 'Drawings',
          fileCount: 3,
          type: 'drawings',
        ),
        DocumentCategoryModel(
          title: 'Invoices',
          fileCount: 2,
          type: 'invoices',
        ),
        DocumentCategoryModel(title: 'Reports', fileCount: 1, type: 'reports'),
        DocumentCategoryModel(
          title: 'Contracts',
          fileCount: 2,
          type: 'contracts',
        ),
      ],
      recentDocuments: const [
        RecentDocumentModel(
          id: 'doc-1',
          title: 'Floor Plan - Final Rev 3',
          category: 'Drawings',
          dateLabel: 'Jan 15',
        ),
        RecentDocumentModel(
          id: 'doc-2',
          title: 'Floor Plan - Final Rev 3',
          category: 'Drawings',
          dateLabel: 'Jan 15',
        ),
        RecentDocumentModel(
          id: 'doc-3',
          title: 'Floor Plan - Final Rev 3',
          category: 'Drawings',
          dateLabel: 'Jan 15',
        ),
      ],
    ),
  ];
}

String _readProjectThumbnail(Map<String, dynamic> json) {
  final direct = _readString(json, [
    'thumbnailUrl',
    'thumbnail',
    'coverImage',
    'image',
    'imageUrl',
    'projectImage',
    'logo',
  ]);
  if (direct.isNotEmpty) return direct;

  final imageObj = json['image'];
  if (imageObj is Map<String, dynamic>) {
    final nested = _readString(imageObj, ['url', 'secure_url', 'src', 'path']);
    if (nested.isNotEmpty) return nested;
  }

  final photos = json['photos'];
  final fromPhotos = _readFirstImageFromCollection(photos);
  if (fromPhotos.isNotEmpty) return fromPhotos;

  final images = json['images'];
  final fromImages = _readFirstImageFromCollection(images);
  if (fromImages.isNotEmpty) return fromImages;

  return '';
}

String _readFirstImageFromCollection(dynamic collection) {
  if (collection is! List) return '';
  for (final item in collection) {
    if (item is String && item.trim().isNotEmpty) {
      return item.trim();
    }
    if (item is Map<String, dynamic>) {
      final nested = _readString(item, ['url', 'secure_url', 'src', 'path']);
      if (nested.isNotEmpty) return nested;
    }
  }
  return '';
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

String _normalizeType(String raw) {
  final value = raw.trim().toLowerCase();
  if (value.contains('draw')) return 'drawings';
  if (value.contains('invoice') || value.contains('bill')) return 'invoices';
  if (value.contains('report')) return 'reports';
  if (value.contains('contract') || value.contains('agreement')) {
    return 'contracts';
  }
  return 'drawings';
}

String _formatDateLabel(String source) {
  if (source.isEmpty) return '';

  final parsed = DateTime.tryParse(source);
  if (parsed == null) return source;

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final local = parsed.toLocal();
  return '${months[local.month - 1]} ${local.day}';
}

String? _readMimeType(Map<String, dynamic> json) {
  final direct = _readString(json, ['mimeType']);
  if (direct.trim().isNotEmpty) {
    return direct.trim();
  }

  final meta = json['meta'];
  if (meta is Map<String, dynamic>) {
    final nested = _readString(meta, ['mimeType', 'mime_type', 'type']);
    if (nested.trim().isNotEmpty) {
      return nested.trim();
    }
  }

  return null;
}
