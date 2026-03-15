import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:stephen_farmer/core/network/api_service/token_meneger.dart';

import '../../data/model/chat_model.dart';
import '../../data/service/chat_socket_service.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repository/chat_repository.dart';

class ChatController extends GetxController {
  ChatController({
    required ChatRepository repository,
    required ChatSocketService socketService,
  }) : _repository = repository,
       _socketService = socketService;

  final ChatRepository _repository;
  final ChatSocketService _socketService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<ChatEntity> chats = <ChatEntity>[].obs;
  final RxList<ChatMessageEntity> messages = <ChatMessageEntity>[].obs;
  final Rxn<ChatEntity> activeChat = Rxn<ChatEntity>();
  final RxString currentUserId = ''.obs;

  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<String>? _readSubscription;

  @override
  void onInit() {
    super.onInit();
    _bindSocket();
    _resolveCurrentUserId();
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      chats.assignAll(await _repository.getMyChats());
    } catch (_) {
      errorMessage.value = 'Failed to load chats.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<ChatEntity> openProjectChat(String projectId) async {
    final chat = await _repository.getOrCreateProjectChat(projectId);
    await _activateChat(chat);
    return chat;
  }

  Future<ChatEntity> openTaskChat(String taskId) async {
    final chat = await _repository.getOrCreateTaskChat(taskId);
    await _activateChat(chat);
    return chat;
  }

  Future<void> loadMessages(String chatId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final loaded = await _repository.getChatMessages(chatId);
      messages.assignAll(loaded.map(_normalizeMessage));
      await _repository.markChatAsRead(chatId);
      _socketService.markRead(chatId);
    } catch (_) {
      errorMessage.value = 'Failed to load messages.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    final chat = activeChat.value;
    if (chat == null || text.trim().isEmpty) return;

    final payload = <String, dynamic>{'message': text.trim()};
    final sent = await _repository.sendMessage(chat.id, payload: payload);
    _appendMessageIfMissing(sent);
  }

  Future<void> _activateChat(ChatEntity chat) async {
    activeChat.value = chat;
    await _socketService.connect();
    _socketService.joinChat(chat.id);
    await loadMessages(chat.id);
  }

  void _bindSocket() {
    _messageSubscription = _socketService.messages.listen((message) {
      if (activeChat.value?.id != message.chatId) return;
      _appendMessageIfMissing(message);
    });
    _readSubscription = _socketService.readReceipts.listen((chatId) {
      if (activeChat.value?.id != chatId) return;
      final updatedChats = chats
          .map(
            (chat) => chat.id == chatId
                ? ChatModel(
                    id: chat.id,
                    projectId: chat.projectId,
                    taskId: chat.taskId,
                    title: chat.title,
                    lastMessage: chat.lastMessage,
                    updatedAt: chat.updatedAt,
                    unreadCount: 0,
                  )
                : chat,
          )
          .toList();
      chats.assignAll(updatedChats);
    });
  }

  void _appendMessageIfMissing(ChatMessageEntity incoming) {
    final normalized = _normalizeMessage(incoming);
    final alreadyExistsById = incoming.id.trim().isNotEmpty &&
        messages.any((m) => m.id == normalized.id);
    if (alreadyExistsById) return;

    messages.add(normalized);
  }

  ChatMessageEntity _normalizeMessage(ChatMessageEntity message) {
    final mine = currentUserId.value.isNotEmpty &&
        message.senderId.trim().isNotEmpty &&
        message.senderId == currentUserId.value;

    return ChatMessageModel(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatar: message.senderAvatar,
      senderRole: message.senderRole,
      text: message.text,
      createdAt: message.createdAt,
      isMine: mine,
    );
  }

  Future<void> _resolveCurrentUserId() async {
    final token = await TokenManager.getToken();
    final id = _extractUserIdFromJwt(token);
    if (id.isEmpty) return;
    currentUserId.value = id;
  }

  String _extractUserIdFromJwt(String? token) {
    if (token == null || token.trim().isEmpty) return '';
    final parts = token.split('.');
    if (parts.length < 2) return '';

    try {
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        final id = data['_id'] ?? data['id'] ?? data['userId'];
        if (id != null && id.toString().trim().isNotEmpty) {
          return id.toString().trim();
        }
      }
    } catch (_) {}
    return '';
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    _readSubscription?.cancel();
    _socketService.disconnect();
    super.onClose();
  }
}
