import 'package:get/get.dart';

import '../core/network/api_service/api_client.dart';
import '../core/network/api_service/api_endpoints.dart';
import 'auth/data/repo/auth_repo_impl.dart';
import 'auth/domain/repo/auth_repo.dart';
import 'auth/presentation/controller/login_controller.dart';
import 'chat/data/repository/chat_repository_impl.dart';
import 'chat/data/service/chat_socket_service.dart';
import 'chat/domain/repository/chat_repository.dart';
import 'chat/presentation/controller/chat_controller.dart';
import 'documents/data/repository/document_repository_impl.dart';
import 'documents/domain/repository/document_repository.dart';
import 'documents/domain/usecase/get_document_projects_usecase.dart';
import 'documents/domain/usecase/upload_project_document_usecase.dart';
import 'documents/presentation/controller/document_controller.dart';
import 'financials/data/repository/financials_repository_impl.dart';
import 'financials/domain/repository/financials_repository.dart';
import 'financials/domain/usecase/get_financials_projects_usecase.dart';
import 'financials/presentation/controller/financials_controller.dart';
import 'notifications/data/repository/notification_repository_impl.dart';
import 'notifications/data/service/notification_socket_service.dart';
import 'notifications/domain/repository/notification_repository.dart';
import 'notifications/domain/usecase/get_notifications_usecase.dart';
import 'notifications/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'notifications/domain/usecase/mark_notification_read_usecase.dart';
import 'notifications/presentation/controller/notification_controller.dart';
import 'progress/data/repository/progress_repository_impl.dart';
import 'progress/domain/repository/progress_repository.dart';
import 'progress/domain/usecase/get_progress_projects_usecase.dart';
import 'progress/domain/usecase/submit_progress_usecase.dart';
import 'progress/presentation/controller/progress_controller.dart';
import 'realtime/data/service/realtime_sync_service.dart';
import 'tasks/data/repository/task_repository_impl.dart';
import 'tasks/domain/repository/task_repository.dart';
import 'tasks/domain/usecase/get_task_projects_usecase.dart';
import 'tasks/presentation/controller/task_controller.dart';

class AppDependencies {
  static void init() {
    // ApiClient globally
    Get.put<ApiClient>(ApiClient(baseUrl), permanent: true);

    // Repositories (lazy)
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<AuthRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProgressRepository>(
      () => ProgressRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        useMockData: false,
      ),
      fenix: true,
    );

    Get.lazyPut<GetProgressProjectsUseCase>(
      () => GetProgressProjectsUseCase(
        repository: Get.find<ProgressRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SubmitProgressUseCase>(
      () => SubmitProgressUseCase(repository: Get.find<ProgressRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProgressController>(
      () => ProgressController(
        getProjectsUseCase: Get.find<GetProgressProjectsUseCase>(),
        submitProgressUseCase: Get.find<SubmitProgressUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<FinancialsRepository>(
      () => FinancialsRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        useMockData: false,
      ),
      fenix: true,
    );

    Get.lazyPut<GetFinancialsProjectsUseCase>(
      () => GetFinancialsProjectsUseCase(
        repository: Get.find<FinancialsRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<FinancialsController>(
      () => FinancialsController(
        getProjectsUseCase: Get.find<GetFinancialsProjectsUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        useMockData: false,
      ),
      fenix: true,
    );

    Get.lazyPut<GetTaskProjectsUseCase>(
      () => GetTaskProjectsUseCase(repository: Get.find<TaskRepository>()),
      fenix: true,
    );

    Get.lazyPut<TaskController>(
      () => TaskController(
        getProjectsUseCase: Get.find<GetTaskProjectsUseCase>(),
        taskRepository: Get.find<TaskRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ChatSocketService>(ChatSocketService.new, fenix: true);

    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<ChatController>(
      () => ChatController(
        repository: Get.find<ChatRepository>(),
        socketService: Get.find<ChatSocketService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DocumentRepository>(
      () => DocumentRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        useMockData: false,
      ),
      fenix: true,
    );

    Get.lazyPut<GetDocumentProjectsUseCase>(
      () => GetDocumentProjectsUseCase(
        repository: Get.find<DocumentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<UploadProjectDocumentUseCase>(
      () => UploadProjectDocumentUseCase(
        repository: Get.find<DocumentRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DocumentController>(
      () => DocumentController(
        getProjectsUseCase: Get.find<GetDocumentProjectsUseCase>(),
        uploadProjectDocumentUseCase: Get.find<UploadProjectDocumentUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );

    Get.lazyPut<NotificationSocketService>(
      NotificationSocketService.new,
      fenix: true,
    );

    Get.lazyPut<RealtimeSyncService>(RealtimeSyncService.new, fenix: true);

    Get.lazyPut<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(
        repository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(
        repository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(
        repository: Get.find<NotificationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        getNotificationsUseCase: Get.find<GetNotificationsUseCase>(),
        markAllNotificationsReadUseCase:
            Get.find<MarkAllNotificationsReadUseCase>(),
        markNotificationReadUseCase: Get.find<MarkNotificationReadUseCase>(),
        socketService: Get.find<NotificationSocketService>(),
      ),
      fenix: true,
    );
  }
}
