import '../../../../core/network/api_service/api_client.dart';
import '../../../../core/network/api_service/api_endpoints.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';
import '../model/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ChatEntity>> getMyChats() async {
    final response = await _apiClient.get(ChatEndpoints.getMyChats);
    final rows = _extractList(
      response.data,
      preferredKeys: const ['chats', 'items', 'data'],
    );
    return rows.map(ChatModel.fromJson).toList();
  }

  @override
  Future<ChatEntity> getOrCreateProjectChat(String projectId) async {
    final response = await _apiClient.get(
      ChatEndpoints.getOrCreateProjectChat(projectId),
    );
    return ChatModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['chat', 'data']),
    );
  }

  @override
  Future<ChatEntity> getOrCreateTaskChat(String taskId) async {
    final response = await _apiClient.get(
      ChatEndpoints.getOrCreateTaskChat(taskId),
    );
    return ChatModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['chat', 'data']),
    );
  }

  @override
  Future<List<ChatMessageEntity>> getChatMessages(String chatId) async {
    final response = await _apiClient.get(
      ChatEndpoints.getChatMessages(chatId),
    );
    final rows = _extractList(
      response.data,
      preferredKeys: const ['messages', 'items', 'data'],
    );
    return rows.map(ChatMessageModel.fromJson).toList();
  }

  @override
  Future<ChatMessageEntity> sendMessage(
    String chatId, {
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiClient.post(
      ChatEndpoints.sendMessage(chatId),
      data: payload,
    );
    return ChatMessageModel.fromJson(
      _extractMap(response.data, preferredKeys: const ['message', 'data']),
    );
  }

  @override
  Future<void> markChatAsRead(
    String chatId, {
    Map<String, dynamic>? payload,
  }) async {
    await _apiClient.patch(
      ChatEndpoints.markChatAsRead(chatId),
      data: payload ?? const <String, dynamic>{},
    );
  }
}

Map<String, dynamic> _extractMap(
  dynamic payload, {
  List<String> preferredKeys = const <String>[],
}) {
  if (payload is Map<String, dynamic>) {
    for (final key in preferredKeys) {
      final value = payload[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return payload;
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _extractList(
  dynamic payload, {
  List<String> preferredKeys = const <String>[],
}) {
  if (payload is List) {
    return payload.whereType<Map<String, dynamic>>().toList();
  }
  if (payload is! Map<String, dynamic>) {
    return const <Map<String, dynamic>>[];
  }

  for (final key in preferredKeys) {
    final value = payload[key];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
  }

  final data = payload['data'];
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().toList();
  }
  if (data is Map<String, dynamic>) {
    return _extractList(data, preferredKeys: preferredKeys);
  }

  return const <Map<String, dynamic>>[];
}
