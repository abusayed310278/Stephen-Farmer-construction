import '../entities/financials_project_entity.dart';

abstract class FinancialsRepository {
  Future<List<FinancialsProjectEntity>> fetchFinancialProjects();
}
