import 'package:stephen_farmer/core/network/api_service/api_client.dart';
import 'package:stephen_farmer/core/network/api_service/api_endpoints.dart';

import '../../domain/entities/progress_entity.dart';
import '../../domain/repository/progress_repository.dart';
import '../model/progress_model.dart';
import '../model/submit_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({ApiClient? apiClient, this.useMockData = true}) : _apiClient = apiClient;

  final ApiClient? _apiClient;
  final bool useMockData;

  @override
  Future<List<ProjectProgressEntity>> fetchProjects() async {
    if (useMockData) {
      return ProjectProgressModel.dummyData;
    }

    if (_apiClient == null) {
      throw StateError('ApiClient is required when useMockData is false.');
    }

    try {
      final response = await _apiClient.get(ProjectEndpoints.getAll);
      final rows = _extractProjectRows(response.data);
      return rows.map(ProjectProgressModel.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch progress projects: $e');
    }
  }

  @override
  Future<void> submitProgress({
    required String projectId,
    required String progressName,
    required int percent,
    required String note,
  }) async {
    if (_apiClient == null) {
      throw StateError('ApiClient is required for submitProgress.');
    }

    final request = SubmitProgressRequestModel(progressName: progressName, percent: percent, note: note);

    try {
      await _apiClient.post(
        ProgressEndpoints.submitProgress(projectId),
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('Failed to submit progress: $e');
    }
  }

  List<Map<String, dynamic>> _extractProjectRows(dynamic payload) {
    dynamic source = payload;

    if (source is Map<String, dynamic>) {
      source = source["data"] ?? source["projects"] ?? source["items"] ?? source["results"] ?? source;

      if (source is Map<String, dynamic>) {
        source = source["projects"] ?? source["items"] ?? source["results"] ?? source["data"] ?? [];
      }
    }

    if (source is List) {
      return source.whereType<Map<String, dynamic>>().toList();
    }

    return <Map<String, dynamic>>[];
  }
}
