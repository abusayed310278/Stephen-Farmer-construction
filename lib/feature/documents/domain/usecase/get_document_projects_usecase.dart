import '../entities/document_project_entity.dart';
import '../repository/document_repository.dart';

class GetDocumentProjectsUseCase {
  const GetDocumentProjectsUseCase({
    required DocumentRepository repository,
  }) : _repository = repository;

  final DocumentRepository _repository;

  Future<List<DocumentProjectEntity>> call() {
    return _repository.fetchProjects();
  }
}
