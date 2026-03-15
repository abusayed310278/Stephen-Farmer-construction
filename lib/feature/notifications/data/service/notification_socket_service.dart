import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/api_service/api_endpoints.dart';
import '../../../../core/network/api_service/token_meneger.dart';
import '../model/app_notification_model.dart';

class NotificationSocketService {
  NotificationSocketService();

  io.Socket? _socket;
  bool _isConnecting = false;
  final _notificationController =
      StreamController<AppNotificationModel>.broadcast();
  final _readController = StreamController<String>.broadcast();
  final _readAllController = StreamController<void>.broadcast();

  Stream<AppNotificationModel> get notifications =>
      _notificationController.stream;
  Stream<String> get readEvents => _readController.stream;
  Stream<void> get readAllEvents => _readAllController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true || _isConnecting) return;
    _isConnecting = true;

    final token = await TokenManager.getToken();
    final userId = _extractUserIdFromJwt(token);
    final socketUrl = _resolveSocketBaseUrl(baseUrl);
    final authToken = token?.trim() ?? '';

    _socket = io.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 999999,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
      'forceNew': false,
      'auth': <String, dynamic>{
        if (authToken.isNotEmpty) 'token': 'Bearer $authToken',
      },
      'extraHeaders': <String, dynamic>{
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      },
    });

    _socket?.onConnect((_) {
      _isConnecting = false;
      if (userId.isNotEmpty) {
        _socket?.emit('joinUserRoom', userId);
      }
    });

    _socket?.onConnectError((_) => _isConnecting = false);
    _socket?.onError((_) => _isConnecting = false);
    _socket?.onDisconnect((_) => _isConnecting = false);

    const notificationEvents = <String>[
      'notification:new',
      'notification',
      'notifications:new',
      'notification:created',
      'new-notification',
      'notification:updated',
    ];
    for (final event in notificationEvents) {
      _socket?.on(event, _onNotificationPayload);
    }
    _socket?.on('notification:read', _onNotificationReadPayload);
    _socket?.on('notification:readAll', (_) {
      _readAllController.add(null);
    });

    _socket?.connect();
  }

  void disconnect() {
    _isConnecting = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _notificationController.close();
    await _readController.close();
    await _readAllController.close();
  }

  void _onNotificationPayload(dynamic payload) {
    final rows = _extractNotificationRows(payload);
    for (final row in rows) {
      _notificationController.add(AppNotificationModel.fromJson(row));
    }
  }

  void _onNotificationReadPayload(dynamic payload) {
    if (payload is! Map<String, dynamic>) return;
    final id = payload['notificationId']?.toString().trim() ?? '';
    if (id.isEmpty) return;
    _readController.add(id);
  }

  List<Map<String, dynamic>> _extractNotificationRows(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final directData = payload['data'];
      if (directData is Map<String, dynamic>) {
        return [directData];
      }
      if (directData is List) {
        return directData.whereType<Map<String, dynamic>>().toList();
      }
      return [payload];
    }
    if (payload is List) {
      return payload.whereType<Map<String, dynamic>>().toList();
    }
    return const <Map<String, dynamic>>[];
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

  String _extractUserIdFromJwt(String? token) {
    if (token == null || token.trim().isEmpty) return '';
    final parts = token.split('.');
    if (parts.length < 2) return '';

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
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
}
