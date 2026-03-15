import 'package:get/get.dart';
import 'dart:async';

import '../../data/model/app_notification_model.dart';
import '../../data/service/notification_socket_service.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/usecase/get_notifications_usecase.dart';
import '../../domain/usecase/mark_all_notifications_read_usecase.dart';
import '../../domain/usecase/mark_notification_read_usecase.dart';

class NotificationController extends GetxController {
  NotificationController({
    GetNotificationsUseCase? getNotificationsUseCase,
    MarkAllNotificationsReadUseCase? markAllNotificationsReadUseCase,
    MarkNotificationReadUseCase? markNotificationReadUseCase,
    NotificationSocketService? socketService,
  }) : _getNotificationsUseCase =
           getNotificationsUseCase ?? Get.find<GetNotificationsUseCase>(),
       _markAllNotificationsReadUseCase =
           markAllNotificationsReadUseCase ??
           Get.find<MarkAllNotificationsReadUseCase>(),
       _markNotificationReadUseCase =
           markNotificationReadUseCase ??
           Get.find<MarkNotificationReadUseCase>(),
       _socketService = socketService ?? Get.find<NotificationSocketService>();

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final NotificationSocketService _socketService;

  final RxBool isLoading = false.obs;
  final RxBool isMarkingAll = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<AppNotificationEntity> notifications =
      <AppNotificationEntity>[].obs;
  StreamSubscription<AppNotificationModel>? _socketSubscription;
  StreamSubscription<String>? _readSubscription;
  StreamSubscription<void>? _readAllSubscription;

  @override
  void onInit() {
    super.onInit();
    refreshNotifications();
    _bindSocket();
  }

  Future<void> refreshNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _getNotificationsUseCase.call();
      notifications
        ..clear()
        ..addAll(_sortLatestFirst(data));
    } catch (_) {
      errorMessage.value = 'Failed to load notifications. Please try again.';
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAll.value) return;
    if (notifications.isEmpty) return;

    final hasUnread = notifications.any((item) => !item.isRead);
    if (!hasUnread) return;

    final previous = List<AppNotificationEntity>.from(notifications);
    notifications.value = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();

    try {
      isMarkingAll.value = true;
      await _markAllNotificationsReadUseCase.call();
    } catch (_) {
      notifications.value = previous;
      Get.snackbar('Error', 'Could not mark all notifications as read.');
    } finally {
      isMarkingAll.value = false;
    }
  }

  Future<void> markSingleAsRead(AppNotificationEntity item) async {
    if (item.isRead) return;

    final index = notifications.indexWhere((e) => e.id == item.id);
    if (index < 0) return;

    final previousItem = notifications[index];
    notifications[index] = previousItem.copyWith(isRead: true);

    try {
      await _markNotificationReadUseCase.call(item.id);
    } catch (_) {
      notifications[index] = previousItem;
      Get.snackbar('Error', 'Could not mark notification as read.');
    }
  }

  List<AppNotificationEntity> get todayNotifications {
    final now = DateTime.now();
    return notifications
        .where((item) => _isSameDay(item.createdAt, now))
        .toList();
  }

  List<AppNotificationEntity> get yesterdayNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return notifications
        .where((item) => _isSameDay(item.createdAt, yesterday))
        .toList();
  }

  List<AppNotificationEntity> get olderNotifications {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return notifications
        .where(
          (item) =>
              !_isSameDay(item.createdAt, now) &&
              !_isSameDay(item.createdAt, yesterday),
        )
        .toList();
  }

  bool get hasUnread => notifications.any((item) => !item.isRead);
  int get unreadCount => notifications.where((item) => !item.isRead).length;

  String timeLabel(AppNotificationEntity item) {
    final now = DateTime.now();
    final diff = now.difference(item.createdAt);

    if (diff.inMinutes < 1) return 'Now';

    if (_isSameDay(item.createdAt, now)) {
      if (diff.inHours < 1) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    }

    if (_isSameDay(item.createdAt, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, ${_formatTime(item.createdAt)}';
    }

    return _formatDate(item.createdAt);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    return '$month ${dateTime.day}, ${_formatTime(dateTime)}';
  }

  List<AppNotificationEntity> _sortLatestFirst(
    List<AppNotificationEntity> source,
  ) {
    final data = List<AppNotificationEntity>.from(source);
    data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return data;
  }

  void _bindSocket() {
    _socketSubscription?.cancel();
    _readSubscription?.cancel();
    _readAllSubscription?.cancel();
    _socketSubscription = _socketService.notifications.listen((incoming) {
      if (incoming.id.trim().isEmpty) return;
      final index = notifications.indexWhere((e) => e.id == incoming.id);
      if (index >= 0) {
        notifications[index] = _mergeNotification(
          current: notifications[index],
          incoming: incoming,
        );
        notifications.assignAll(_sortLatestFirst(notifications.toList()));
        return;
      }

      notifications.insert(0, incoming);
      notifications.assignAll(_sortLatestFirst(notifications.toList()));
    });
    _readSubscription = _socketService.readEvents.listen((notificationId) {
      final index = notifications.indexWhere((e) => e.id == notificationId);
      if (index < 0) return;
      final current = notifications[index];
      notifications[index] = current.copyWith(isRead: true);
    });
    _readAllSubscription = _socketService.readAllEvents.listen((_) {
      notifications.value = notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
    });

    _socketService.connect();
  }

  AppNotificationEntity _mergeNotification({
    required AppNotificationEntity current,
    required AppNotificationEntity incoming,
  }) {
    final incomingTitle = incoming.title.trim();
    final incomingMessage = incoming.message.trim();
    final incomingType = incoming.type.trim();

    return current.copyWith(
      title: incomingTitle.isEmpty ? current.title : incomingTitle,
      message: incomingMessage.isEmpty ? current.message : incomingMessage,
      type: incomingType.isEmpty ? current.type : incomingType,
      createdAt: incoming.createdAt,
      isRead: incoming.isRead,
    );
  }

  @override
  void onClose() {
    _socketSubscription?.cancel();
    _readSubscription?.cancel();
    _readAllSubscription?.cancel();
    _socketService.disconnect();
    super.onClose();
  }
}
