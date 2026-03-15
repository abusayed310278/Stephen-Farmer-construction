import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/network/api_service/api_endpoints.dart';
import '../../../../core/network/api_service/token_meneger.dart';

enum RealtimeArea {
  all,
  updates,
  progress,
  financials,
  tasks,
  documents,
  notifications,
}

class RealtimeSyncEvent {
  const RealtimeSyncEvent({required this.areas, required this.eventName});

  final Set<RealtimeArea> areas;
  final String eventName;
}

class RealtimeSyncService {
  RealtimeSyncService();

  io.Socket? _socket;
  bool _isConnecting = false;
  bool _isConnected = false;
  final _events = StreamController<RealtimeSyncEvent>.broadcast();
  final _connectionState = StreamController<bool>.broadcast();

  Stream<RealtimeSyncEvent> get events => _events.stream;
  Stream<bool> get connectionState => _connectionState.stream;
  bool get isConnected => _isConnected;

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
      _isConnected = true;
      _connectionState.add(true);
      if (userId.isNotEmpty) {
        _socket?.emit('joinUserRoom', userId);
      }
    });
    _socket?.onConnectError((_) {
      _isConnecting = false;
      _isConnected = false;
      _connectionState.add(false);
    });
    _socket?.onError((_) {
      _isConnecting = false;
      _isConnected = false;
      _connectionState.add(false);
    });
    _socket?.onDisconnect((_) {
      _isConnecting = false;
      _isConnected = false;
      _connectionState.add(false);
    });

    final scopedEvents = <String, Set<RealtimeArea>>{
      'project:created': <RealtimeArea>{RealtimeArea.all},
      'project:updated': <RealtimeArea>{RealtimeArea.all},
      'project:deleted': <RealtimeArea>{RealtimeArea.all},
      'update:created': <RealtimeArea>{RealtimeArea.updates},
      'update:updated': <RealtimeArea>{RealtimeArea.updates},
      'update:deleted': <RealtimeArea>{RealtimeArea.updates},
      'progress:created': <RealtimeArea>{RealtimeArea.progress},
      'progress:updated': <RealtimeArea>{RealtimeArea.progress},
      'task:created': <RealtimeArea>{RealtimeArea.tasks},
      'task:updated': <RealtimeArea>{RealtimeArea.tasks},
      'task:deleted': <RealtimeArea>{RealtimeArea.tasks},
      'task:approved': <RealtimeArea>{RealtimeArea.tasks},
      'task:rejected': <RealtimeArea>{RealtimeArea.tasks},
      'financial:updated': <RealtimeArea>{RealtimeArea.financials},
      'payment:updated': <RealtimeArea>{RealtimeArea.financials},
      'document:created': <RealtimeArea>{RealtimeArea.documents},
      'document:updated': <RealtimeArea>{RealtimeArea.documents},
      'document:deleted': <RealtimeArea>{RealtimeArea.documents},
      'notification:new': <RealtimeArea>{RealtimeArea.notifications},
      'notification:updated': <RealtimeArea>{RealtimeArea.notifications},
      'notification:read': <RealtimeArea>{RealtimeArea.notifications},
      'app:refresh': <RealtimeArea>{RealtimeArea.all},
    };

    for (final entry in scopedEvents.entries) {
      _socket?.on(entry.key, (payload) {
        final payloadAreas = _extractAreasFromPayload(payload);
        final areas = <RealtimeArea>{...entry.value, ...payloadAreas};
        _events.add(RealtimeSyncEvent(areas: areas, eventName: entry.key));
      });
    }

    _socket?.connect();
  }

  void disconnect() {
    _isConnecting = false;
    _isConnected = false;
    _connectionState.add(false);
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _events.close();
    await _connectionState.close();
  }

  Set<RealtimeArea> _extractAreasFromPayload(dynamic payload) {
    if (payload is! Map) return const <RealtimeArea>{};
    final source = <String>[
      payload['module']?.toString() ?? '',
      payload['entity']?.toString() ?? '',
      payload['resource']?.toString() ?? '',
      payload['type']?.toString() ?? '',
      payload['event']?.toString() ?? '',
    ].join(' ').toLowerCase();

    final areas = <RealtimeArea>{};
    if (source.contains('update')) areas.add(RealtimeArea.updates);
    if (source.contains('progress')) areas.add(RealtimeArea.progress);
    if (source.contains('task')) areas.add(RealtimeArea.tasks);
    if (source.contains('financial') || source.contains('payment')) {
      areas.add(RealtimeArea.financials);
    }
    if (source.contains('document') || source.contains('file')) {
      areas.add(RealtimeArea.documents);
    }
    if (source.contains('notification')) areas.add(RealtimeArea.notifications);
    if (source.contains('project')) areas.add(RealtimeArea.all);
    return areas;
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
