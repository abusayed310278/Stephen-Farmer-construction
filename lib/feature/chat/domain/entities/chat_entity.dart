class ChatEntity {
  final String id;
  final String projectId;
  final String taskId;
  final String title;
  final String lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    this.projectId = '',
    this.taskId = '',
    this.title = '',
    this.lastMessage = '',
    this.updatedAt,
    this.unreadCount = 0,
  });
}

class ChatMessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String senderRole;
  final String text;
  final DateTime? createdAt;
  final bool isMine;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    this.senderId = '',
    this.senderName = '',
    this.senderAvatar = '',
    this.senderRole = '',
    required this.text,
    this.createdAt,
    this.isMine = false,
  });
}
