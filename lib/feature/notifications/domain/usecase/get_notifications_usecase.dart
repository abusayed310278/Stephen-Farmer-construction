import '../entities/app_notification_entity.dart';
import '../repository/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase({required NotificationRepository repository})
    : _repository = repository;

  final NotificationRepository _repository;

  Future<List<AppNotificationEntity>> call() {
    return _repository.fetchNotifications();
  }
}
