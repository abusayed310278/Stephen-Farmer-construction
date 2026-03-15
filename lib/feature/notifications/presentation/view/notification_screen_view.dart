import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stephen_farmer/core/common/role_bg_color.dart';
import 'package:stephen_farmer/feature/auth/presentation/controller/login_controller.dart';

import '../../domain/entities/app_notification_entity.dart';
import '../controller/notification_controller.dart';

class NotificationScreenView extends GetView<NotificationController> {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<LoginController>();

    return Obx(() {
      final role = authController.role.value;
      final isInterior = RoleBgColor.isInterior(role);

      final Color titleColor = isInterior
          ? const Color(0xFF1D1D1D)
          : Colors.white;
      final Color actionColor = const Color(0xFFA77935);
      final Color sectionColor = isInterior
          ? const Color(0xFF7D7D7D)
          : Colors.white;
      final Color cardBackground = isInterior
          ? const Color(0xFFD9D6CD)
          : const Color(0xFF1A2329);
      final Color cardBorder = isInterior
          ? const Color(0xFF8F8A81)
          : const Color(0xFF4A565D);
      final Color subtitleColor = isInterior
          ? const Color(0xFF585858)
          : const Color(0xFF8E8E93);
      final Color messageColor = isInterior
          ? const Color(0xFF4C4C4C)
          : Colors.white;
      final sectionTextStyle = GoogleFonts.manrope(
        color: sectionColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1,
        letterSpacing: 0,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: RoleBgColor.overlayStyle(role),
        child: Scaffold(
          backgroundColor: RoleBgColor.scaffoldColor(role),
          body: Container(
            decoration: RoleBgColor.decoration(role),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 128,
                          height: 27,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Notifications',
                              style: GoogleFonts.manrope(
                                color: titleColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  controller.hasUnread &&
                                      !controller.isMarkingAll.value
                                  ? controller.markAllAsRead
                                  : null,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                controller.isMarkingAll.value
                                    ? 'Marking...'
                                    : 'Mark all as read',
                                style: GoogleFonts.manrope(
                                  color: actionColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: isInterior
                          ? const Color(0xFF9A968E)
                          : const Color(0xFF3A454C),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: controller.refreshNotifications,
                              child: ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                children: [
                                  if (controller
                                      .todayNotifications
                                      .isNotEmpty) ...[
                                    Text('Today', style: sectionTextStyle),
                                    const SizedBox(height: 10),
                                    ...controller.todayNotifications.map(
                                      (item) => _NotificationCard(
                                        item: item,
                                        onTap: () =>
                                            controller.markSingleAsRead(item),
                                        isInterior: isInterior,
                                        cardBackground: cardBackground,
                                        cardBorder: cardBorder,
                                        subtitleColor: subtitleColor,
                                        messageColor: messageColor,
                                        timeLabel: controller.timeLabel(item),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  if (controller
                                      .yesterdayNotifications
                                      .isNotEmpty) ...[
                                    Text('Yesterday', style: sectionTextStyle),
                                    const SizedBox(height: 10),
                                    ...controller.yesterdayNotifications.map(
                                      (item) => _NotificationCard(
                                        item: item,
                                        onTap: () =>
                                            controller.markSingleAsRead(item),
                                        isInterior: isInterior,
                                        cardBackground: cardBackground,
                                        cardBorder: cardBorder,
                                        subtitleColor: subtitleColor,
                                        messageColor: messageColor,
                                        timeLabel: controller.timeLabel(item),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  if (controller
                                      .olderNotifications
                                      .isNotEmpty) ...[
                                    Text('Earlier', style: sectionTextStyle),
                                    const SizedBox(height: 10),
                                    ...controller.olderNotifications.map(
                                      (item) => _NotificationCard(
                                        item: item,
                                        onTap: () =>
                                            controller.markSingleAsRead(item),
                                        isInterior: isInterior,
                                        cardBackground: cardBackground,
                                        cardBorder: cardBorder,
                                        subtitleColor: subtitleColor,
                                        messageColor: messageColor,
                                        timeLabel: controller.timeLabel(item),
                                      ),
                                    ),
                                  ],
                                  if (controller.notifications.isEmpty &&
                                      controller.errorMessage.value.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 42),
                                      child: Center(
                                        child: Text(
                                          'No notifications yet',
                                          style: TextStyle(
                                            color: subtitleColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (controller.errorMessage.value.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 18),
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: const TextStyle(
                                          color: Color(0xFFFF7A7A),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.isInterior,
    required this.cardBackground,
    required this.cardBorder,
    required this.subtitleColor,
    required this.messageColor,
    required this.timeLabel,
  });

  final AppNotificationEntity item;
  final VoidCallback onTap;
  final bool isInterior;
  final Color cardBackground;
  final Color cardBorder;
  final Color subtitleColor;
  final Color messageColor;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveIconColors(item.type, isInterior);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 73),
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cardBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _resolveIcon(item.type),
                  size: 24,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _toHeaderText(item.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              color: subtitleColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: GoogleFonts.manrope(
                            color: subtitleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 16 / 12,
                            letterSpacing: 0,
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          const _UnreadDot(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: messageColor,
                        fontSize: 14,
                        fontWeight: item.isRead
                            ? FontWeight.w600
                            : FontWeight.w700,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    if (item.message.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _toHeaderText(String type) {
    if (type.trim().isEmpty) return 'General';

    final normalized = type.trim().toLowerCase();
    if (normalized.contains('site') || normalized.contains('update')) {
      return 'Site Updates';
    }
    if (normalized.contains('budget') || normalized.contains('payment')) {
      return 'Budget Alert';
    }

    return normalized
        .split(RegExp(r'[_\-\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  IconData _resolveIcon(String type) {
    final normalized = type.trim().toLowerCase();

    if (normalized.contains('site') || normalized.contains('update')) {
      return Icons.photo_camera_rounded;
    }
    if (normalized.contains('financial') ||
        normalized.contains('invoice') ||
        normalized.contains('payment')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (normalized.contains('task')) {
      return Icons.task_alt_rounded;
    }
    if (normalized.contains('document') || normalized.contains('file')) {
      return Icons.folder_rounded;
    }
    if (normalized.contains('budget') || normalized.contains('alert')) {
      return Icons.warning_amber_rounded;
    }

    return Icons.notifications_rounded;
  }

  _IconColors _resolveIconColors(String type, bool isInterior) {
    final normalized = type.trim().toLowerCase();

    if (normalized.contains('site') || normalized.contains('update')) {
      return _IconColors(
        background: isInterior
            ? const Color(0xFF34352E)
            : const Color(0xFF2A2F2A),
        foreground: const Color(0xFFE0B32F),
      );
    }

    if (normalized.contains('financial') ||
        normalized.contains('invoice') ||
        normalized.contains('payment')) {
      return _IconColors(
        background: isInterior
            ? const Color(0xFF1E463F)
            : const Color(0xFF163A35),
        foreground: const Color(0xFF1BE4A4),
      );
    }

    if (normalized.contains('task')) {
      return _IconColors(
        background: isInterior
            ? const Color(0xFF1A3358)
            : const Color(0xFF1A2F4B),
        foreground: const Color(0xFF4C95FF),
      );
    }

    if (normalized.contains('document') || normalized.contains('file')) {
      return _IconColors(
        background: isInterior
            ? const Color(0xFF3B352A)
            : const Color(0xFF2E3027),
        foreground: const Color(0xFFF0A500),
      );
    }

    if (normalized.contains('budget') || normalized.contains('alert')) {
      return _IconColors(
        background: isInterior
            ? const Color(0xFF432D39)
            : const Color(0xFF3A2731),
        foreground: const Color(0xFFFF4D73),
      );
    }

    return _IconColors(
      background: isInterior
          ? const Color(0xFF3A3A3A)
          : const Color(0xFF29343A),
      foreground: const Color(0xFFD09A2F),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFEDA83A),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _IconColors {
  const _IconColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
