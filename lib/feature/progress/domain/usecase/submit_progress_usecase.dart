import '../repository/progress_repository.dart';

class SubmitProgressUseCase {
  const SubmitProgressUseCase({
    required ProgressRepository repository,
  }) : _repository = repository;

  final ProgressRepository _repository;

  Future<void> call({
    required String projectId,
    required String progressName,
    required int percent,
    required String note,
  }) {
    return _repository.submitProgress(
      projectId: projectId,
      progressName: progressName,
      percent: percent,
      note: note,
    );
  }
}
