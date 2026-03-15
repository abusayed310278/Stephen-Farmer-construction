import '../entities/progress_entity.dart';
import '../repository/progress_repository.dart';

class GetProgressProjectsUseCase {
  const GetProgressProjectsUseCase({
    required ProgressRepository repository,
  }) : _repository = repository;

  final ProgressRepository _repository;

  Future<List<ProjectProgressEntity>> call() {
    return _repository.fetchProjects();
  }
}
