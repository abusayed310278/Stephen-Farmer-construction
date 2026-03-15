import '../entities/progress_entity.dart';

abstract class ProgressRepository {
  Future<List<ProjectProgressEntity>> fetchProjects();

  Future<void> submitProgress({
    required String projectId,
    required String progressName,
    required int percent,
    required String note,
  });
}
