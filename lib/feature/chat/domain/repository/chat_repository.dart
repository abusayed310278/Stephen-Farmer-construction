import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Future<List<ChatEntity>> getMyChats();
  Future<ChatEntity> getOrCreateProjectChat(String projectId);
  Future<ChatEntity> getOrCreateTaskChat(String taskId);
  Future<List<ChatMessageEntity>> getChatMessages(String chatId);
  Future<ChatMessageEntity> sendMessage(
    String chatId, {
    required Map<String, dynamic> payload,
  });
  Future<void> markChatAsRead(String chatId, {Map<String, dynamic>? payload});
}
