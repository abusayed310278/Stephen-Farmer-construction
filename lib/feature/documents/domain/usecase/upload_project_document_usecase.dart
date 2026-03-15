import 'dart:io';

import '../repository/document_repository.dart';

class UploadProjectDocumentUseCase {
  const UploadProjectDocumentUseCase({required DocumentRepository repository})
    : _repository = repository;

  final DocumentRepository _repository;

  Future<void> call({
    required String projectId,
    required File document,
    required String title,
    required String category,
  }) {
    return _repository.uploadDocument(
      projectId: projectId,
      document: document,
      title: title,
      category: category,
    );
  }
}
