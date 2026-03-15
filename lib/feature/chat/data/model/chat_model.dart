import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    super.projectId,
    super.taskId,
    super.title,
    super.lastMessage,
    super.updatedAt,
    super.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: _readString(json, ['_id', 'id', 'chatId']),
      projectId: _readString(json, ['project', 'projectId']),
      taskId: _readString(json, ['task', 'taskId']),
      title: _readString(json, ['title', 'name', 'chatTitle']),
      lastMessage: _readString(json, ['lastMessage', 'message', 'text']),
      updatedAt: _readDateTime(json['updatedAt'] ?? json['lastMessageAt']),
      unreadCount: _readInt(json, ['unreadCount', 'unreadMessages']),
    );
  }
}

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatId,
    super.senderId,
    super.senderName,
    super.senderAvatar,
    super.senderRole,
    required super.text,
    super.createdAt,
    super.isMine,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String currentUserId = '',
  }) {
    final senderRaw = json['sender'] ?? json['user'] ?? json['author'];
    final sender = senderRaw is Map<String, dynamic>
        ? senderRaw
        : <String, dynamic>{};
    final senderId = _readString(sender, ['_id', 'id', 'userId']);
    return ChatMessageModel(
      id: _readString(json, ['_id', 'id', 'messageId']),
      chatId: _readEntityId(json['chat'] ?? json['chatId'] ?? json['chatRoom']),
      senderId: senderId,
      senderName: _readString(sender, ['name', 'fullName'], fallback: 'User'),
      senderAvatar: _readAvatarUrl(sender),
      senderRole: _readString(sender, ['role', 'userRole']),
      text: _readString(json, ['text', 'message', 'content', 'body']),
      createdAt: _readDateTime(json['createdAt'] ?? json['timestamp']),
      isMine: currentUserId.isNotEmpty && senderId == currentUserId,
    );
  }

  factory ChatMessageModel.fromSocket(
    Map<String, dynamic> json, {
    String currentUserId = '',
  }) {
    return ChatMessageModel.fromJson(json, currentUserId: currentUserId);
  }
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

String _readEntityId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is Map<String, dynamic>) {
    return _readString(value, ['_id', 'id', 'chatId', 'chatRoom']);
  }
  return value.toString().trim();
}

int _readInt(Map<String, dynamic> json, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}

DateTime? _readDateTime(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

String _readAvatarUrl(Map<String, dynamic> sender) {
  for (final key in const ['avatar', 'image', 'profileImage', 'photoUrl']) {
    final value = sender[key];
    final resolved = _extractMediaUrl(value);
    if (resolved.isNotEmpty) return resolved;
  }
  return '';
}

String _extractMediaUrl(dynamic raw) {
  if (raw == null) return '';
  if (raw is String) {
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    return value;
  }
  if (raw is Map<String, dynamic>) {
    for (final key in const [
      'url',
      'secure_url',
      'secureUrl',
      'src',
      'path',
      'location',
      'imageUrl',
      'avatar',
    ]) {
      final nested = raw[key];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
    if (raw.containsKey('document')) {
      return _extractMediaUrl(raw['document']);
    }
  }
  return '';
}
