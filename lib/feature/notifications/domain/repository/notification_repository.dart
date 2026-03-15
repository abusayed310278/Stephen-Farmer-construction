import '../entities/app_notification_entity.dart';

abstract class NotificationRepository {
  Future<List<AppNotificationEntity>> fetchNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(String notificationId);
}
