import '../entities/task_project_entity.dart';

abstract class TaskRepository {
  Future<List<TaskProjectEntity>> fetchTaskProjects();
  Future<List<TaskItemEntity>> fetchTasks({Map<String, dynamic>? query});
  Future<TaskItemEntity> getTaskDetails(String taskId);
  Future<TaskItemEntity> createTask(Map<String, dynamic> payload);
  Future<TaskItemEntity> updateTaskByManager(
    String taskId,
    Map<String, dynamic> payload,
  );
  Future<TaskItemEntity> resubmitTaskForApproval(
    String taskId, {
    Map<String, dynamic>? payload,
  });
  Future<TaskItemEntity> approveTask(
    String taskId, {
    Map<String, dynamic>? payload,
  });
  Future<TaskItemEntity> rejectTask(
    String taskId, {
    Map<String, dynamic>? payload,
  });
  Future<TaskItemEntity> updateTaskStatus(
    String taskId, {
    required Map<String, dynamic> payload,
  });
}
