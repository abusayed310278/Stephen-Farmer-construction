import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/api_service/api_endpoints.dart';
import '../../../../core/network/api_service/token_meneger.dart';
import '../model/chat_model.dart';

class ChatSocketService {
  ChatSocketService();

  io.Socket? _socket;
  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _readController = StreamController<String>.broadcast();

  Stream<ChatMessageModel> get messages => _messageController.stream;
  Stream<String> get readReceipts => _readController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await TokenManager.getToken();
    final socketUrl = _resolveSocketBaseUrl(baseUrl);
    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': <String, dynamic>{
        if (token != null && token.isNotEmpty) 'token': 'Bearer $token',
      },
    });

    _socket?.onConnect((_) {});
    _socket?.on('chat:message', (payload) {
      if (payload is Map<String, dynamic>) {
        _messageController.add(ChatMessageModel.fromSocket(payload));
      }
    });
    _socket?.on('chat:read', (payload) {
      if (payload is Map<String, dynamic>) {
        final chatId = payload['chatId']?.toString() ?? '';
        if (chatId.isNotEmpty) {
          _readController.add(chatId);
        }
      }
    });
    _socket?.connect();
  }

  void joinChat(String chatId) {
    if (chatId.trim().isEmpty) return;
    // Backend listens on `joinChatRoom` with raw chat id payload.
    _socket?.emit('joinChatRoom', chatId);
  }

  void leaveChat(String chatId) {
    if (chatId.trim().isEmpty) return;
    _socket?.emit('chat:leave', <String, dynamic>{'chatId': chatId});
  }

  void sendMessage({
    required String chatId,
    required Map<String, dynamic> payload,
  }) {
    if (chatId.trim().isEmpty) return;
    _socket?.emit('chat:message', <String, dynamic>{
      'chatId': chatId,
      ...payload,
    });
  }

  void markRead(String chatId) {
    if (chatId.trim().isEmpty) return;
    _socket?.emit('chat:read', <String, dynamic>{'chatId': chatId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _messageController.close();
    await _readController.close();
  }

  String _resolveSocketBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    if (trimmed.isEmpty) return trimmed;

    final withoutApi = trimmed.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    final uri = Uri.tryParse(withoutApi);
    if (uri == null || uri.host.isEmpty) return withoutApi;

    var host = uri.host;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      host = '10.0.2.2';
    }

    return Uri(
      scheme: uri.scheme,
      host: host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }
}
