import '../entities/task_project_entity.dart';
import '../repository/task_repository.dart';

class GetTaskProjectsUseCase {
  const GetTaskProjectsUseCase({
    required TaskRepository repository,
  }) : _repository = repository;

  final TaskRepository _repository;

  Future<List<TaskProjectEntity>> call() {
    return _repository.fetchTaskProjects();
  }
}
