import '../repository/notification_repository.dart';

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;

  Future<void> call(String notificationId) {
    return _repository.markAsRead(notificationId);
  }
}
