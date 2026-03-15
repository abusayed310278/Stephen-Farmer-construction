import '../entities/financials_project_entity.dart';
import '../repository/financials_repository.dart';

class GetFinancialsProjectsUseCase {
  const GetFinancialsProjectsUseCase({
    required FinancialsRepository repository,
  }) : _repository = repository;

  final FinancialsRepository _repository;

  Future<List<FinancialsProjectEntity>> call() {
    return _repository.fetchFinancialProjects();
  }
}
