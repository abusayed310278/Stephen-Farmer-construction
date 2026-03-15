import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';

import '../../domain/entities/financials_project_entity.dart';
import '../../domain/repository/financials_repository.dart';
import '../model/financials_project_model.dart';

class FinancialsRepositoryImpl implements FinancialsRepository {
  FinancialsRepositoryImpl({
    required ApiClient apiClient,
    this.useMockData = true,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final bool useMockData;

  @override
  Future<List<FinancialsProjectEntity>> fetchFinancialProjects() async {
    if (useMockData) {
      return FinancialsProjectModel.dummyData;
    }

    try {
      final response = await _apiClient.get(FinancialsEndpoints.getProjects);
      final rows = _extractFinancialRows(response.data);
      return rows.map(FinancialsProjectModel.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch financial projects: $e');
    }
  }

  List<Map<String, dynamic>> _extractFinancialRows(dynamic payload) {
    dynamic source = payload;

    if (source is Map<String, dynamic>) {
      source = source["data"] ??
          source["projects"] ??
          source["financialProjects"] ??
          source["items"] ??
          source["results"] ??
          source;

      if (source is Map<String, dynamic>) {
        source = source["financialProjects"] ??
            source["projects"] ??
            source["items"] ??
            source["results"] ??
            source["data"] ??
            [];
      }
    }

    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList();
    }
    return <Map<String, dynamic>>[];
  }
}
