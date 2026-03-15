class DocumentCategoryEntity {
  final String title;
  final int fileCount;
  final String type;

  const DocumentCategoryEntity({
    required this.title,
    required this.fileCount,
    required this.type,
  });
}

class RecentDocumentEntity {
  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final String? fileUrl;
  final String? mimeType;

  const RecentDocumentEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    this.fileUrl,
    this.mimeType,
  });
}

class DocumentProjectEntity {
  final String projectId;
  final String projectName;
  final String projectAddress;
  final String? thumbnailUrl;
  final List<DocumentCategoryEntity> categories;
  final List<RecentDocumentEntity> recentDocuments;

  const DocumentProjectEntity({
    required this.projectId,
    required this.projectName,
    required this.projectAddress,
    this.thumbnailUrl,
    required this.categories,
    required this.recentDocuments,
  });
}
