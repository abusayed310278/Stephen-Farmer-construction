import '../repository/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  const MarkAllNotificationsReadUseCase({
    required NotificationRepository repository,
  }) : _repository = repository;

  final NotificationRepository _repository;

  Future<void> call() {
    return _repository.markAllAsRead();
  }
}
