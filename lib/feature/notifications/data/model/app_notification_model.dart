import '../../domain/entities/app_notification_entity.dart';

class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    required super.isRead,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final title = _asString(
      json['title'] ??
          json['name'] ??
          json['subject'] ??
          json['heading'] ??
          json['event'] ??
          json['category'],
    );
    final message = _asString(
      json['message'] ?? json['body'] ?? json['description'] ?? json['text'],
    );
    final type = _asString(
      json['type'] ?? json['category'] ?? json['eventType'] ?? json['kind'],
    );

    return AppNotificationModel(
      id: _asString(json['_id'] ?? json['id'] ?? json['notificationId']),
      title: title.isEmpty ? 'Notification' : title,
      message: message,
      type: type.isEmpty ? 'general' : type,
      createdAt: _parseDateTime(
        json['createdAt'] ?? json['timestamp'] ?? json['date'] ?? json['time'],
      ),
      isRead: _parseReadFlag(json),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return '';
      final objectIdMatch = RegExp(
        "ObjectId\\(['\\\"]?([a-fA-F0-9]{24})['\\\"]?\\)",
      ).firstMatch(trimmed);
      if (objectIdMatch != null) {
        return objectIdMatch.group(1) ?? trimmed;
      }
      return trimmed;
    }
    if (value is Map) {
      final fromOid = _asString(value[r'$oid'] ?? value['_id'] ?? value['id']);
      if (fromOid.isNotEmpty) return fromOid;
      final fromDate = _asString(value[r'$date']);
      if (fromDate.isNotEmpty) return fromDate;
      return '';
    }
    return value.toString().trim();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Map) {
      final nested = value[r'$date'] ?? value['date'] ?? value['createdAt'];
      return _parseDateTime(nested);
    }
    if (value is String && value.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) {
        return parsed.toLocal();
      }
    }
    if (value is int) {
      final millis = value > 9999999999 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis).toLocal();
    }
    return DateTime.now();
  }

  static bool _parseReadFlag(Map<String, dynamic> json) {
    final dynamic raw =
        json['isRead'] ?? json['read'] ?? json['seen'] ?? json['status'];

    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      return normalized == 'true' ||
          normalized == 'read' ||
          normalized == 'seen' ||
          normalized == '1';
    }
    return false;
  }
}
