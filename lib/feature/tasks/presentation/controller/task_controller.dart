import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/task_project_entity.dart';
import '../../domain/usecase/get_task_projects_usecase.dart';
import '../../domain/repository/task_repository.dart';

class TaskController extends GetxController {
  TaskController({
    GetTaskProjectsUseCase? getProjectsUseCase,
    TaskRepository? taskRepository,
  }) : _getProjectsUseCase =
           getProjectsUseCase ?? Get.find<GetTaskProjectsUseCase>(),
       _taskRepository = taskRepository ?? Get.find<TaskRepository>();

  final GetTaskProjectsUseCase _getProjectsUseCase;
  final TaskRepository _taskRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TaskProjectEntity> projects = <TaskProjectEntity>[].obs;
  final RxInt selectedProjectIndex = 0.obs;
  final RxBool isProjectMenuOpen = false.obs;
  final RxInt managerPhaseTab = 0.obs;
  final RxInt selectedManagerTaskIndex = (-1).obs;
  final Rxn<TaskItemEntity> taskDetails = Rxn<TaskItemEntity>();

  @override
  void onInit() {
    super.onInit();
    refreshProjects();
  }

  TaskProjectEntity? get selectedProject {
    if (projects.isEmpty) return null;
    return projects[_safeIndex];
  }

  int get _safeIndex {
    if (projects.isEmpty) return 0;
    final current = selectedProjectIndex.value;
    if (current < 0) return 0;
    if (current >= projects.length) return projects.length - 1;
    return current;
  }

  Future<void> refreshProjects() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _getProjectsUseCase.call();
      projects.assignAll(data);
      _normalizeState();
    } catch (_) {
      errorMessage.value = 'Failed to load task data. Please try again.';
      projects.clear();
      _normalizeState();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleProjectMenu() {
    isProjectMenuOpen.value = !isProjectMenuOpen.value;
  }

  void selectProject(int index) {
    if (index < 0 || index >= projects.length) return;
    selectedProjectIndex.value = index;
    isProjectMenuOpen.value = false;
    managerPhaseTab.value = 0;
    selectedManagerTaskIndex.value = -1;
  }

  void setManagerPhaseTab(int index) {
    if (index < 0 || index > 1) return;
    managerPhaseTab.value = index;
    selectedManagerTaskIndex.value = -1;
  }

  void selectManagerTask(int index) {
    selectedManagerTaskIndex.value = index;
  }

  void _normalizeState() {
    selectedProjectIndex.value = _safeIndex;
    selectedManagerTaskIndex.value = -1;
    if (projects.length <= 1) {
      isProjectMenuOpen.value = false;
    }
  }

  Future<void> fetchTaskDetails(String taskId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      taskDetails.value = await _taskRepository.getTaskDetails(taskId);
    } catch (_) {
      errorMessage.value = 'Failed to load task details.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<TaskItemEntity?> createTask(Map<String, dynamic> payload) async {
    return _runTaskMutation(() => _taskRepository.createTask(payload));
  }

  Future<TaskItemEntity?> updateTaskByManager(
    String taskId,
    Map<String, dynamic> payload,
  ) async {
    return _runTaskMutation(
      () => _taskRepository.updateTaskByManager(taskId, payload),
    );
  }

  Future<TaskItemEntity?> resubmitTaskForApproval(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    return _runTaskMutation(
      () => _taskRepository.resubmitTaskForApproval(taskId, payload: payload),
    );
  }

  Future<TaskItemEntity?> approveTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    return _runTaskMutation(
      () => _taskRepository.approveTask(taskId, payload: payload),
    );
  }

  Future<TaskItemEntity?> rejectTask(
    String taskId, {
    Map<String, dynamic>? payload,
  }) async {
    return _runTaskMutation(
      () => _taskRepository.rejectTask(taskId, payload: payload),
    );
  }

  Future<TaskItemEntity?> updateTaskStatus(
    String taskId, {
    required Map<String, dynamic> payload,
  }) async {
    return _runTaskMutation(
      () => _taskRepository.updateTaskStatus(taskId, payload: payload),
    );
  }

  Future<TaskItemEntity?> _runTaskMutation(
    Future<TaskItemEntity> Function() action,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await action();
      taskDetails.value = result;
      await refreshProjects();
      return result;
    } catch (error) {
      errorMessage.value = _resolveTaskErrorMessage(error);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String _resolveTaskErrorMessage(Object error) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map<String, dynamic>) {
        final message = payload['message']?.toString().trim() ?? '';
        if (message.isNotEmpty) return message;
        final errorText = payload['error']?.toString().trim() ?? '';
        if (errorText.isNotEmpty) return errorText;
      }
    }
    return 'Task request failed. Please try again.';
  }
}
