import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages real-time WebSocket connection, message sending, and reconnection lifecycle.
class OnlineSocketClient {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;
  Timer? _reconnectTimer;
  bool _disposed = false;

  bool get isConnected => _channel != null;

  /// Connects to the given WebSocket URI.
  Future<void> connect({
    required String wsUrl,
    required void Function(String message) onMessage,
    required VoidCallback onConnected,
    required VoidCallback onDisconnected,
    required void Function(dynamic error) onError,
  }) async {
    if (_disposed) return;
    _channelSub?.cancel();
    _channel?.sink.close();

    try {
      final wsUri = Uri.parse(wsUrl);
      final channel = WebSocketChannel.connect(wsUri);
      _channel = channel;

      _channelSub = channel.stream.listen(
        (data) => onMessage(data.toString()),
        onDone: () {
          debugPrint('[OnlineSocketClient] WebSocket closed.');
          _channel = null;
          onDisconnected();
        },
        onError: (err) {
          debugPrint('[OnlineSocketClient] WebSocket error: $err');
          _channel = null;
          onError(err);
        },
      );

      await channel.ready;
      onConnected();
    } catch (e) {
      debugPrint('[OnlineSocketClient] Connect exception: $e');
      _channel = null;
      onError(e);
    }
  }

  /// Sends a typed JSON message over WebSocket if connected.
  void send(String type, Map<String, dynamic> payload) {
    if (_channel != null) {
      final msg = jsonEncode({
        'type': type,
        ...payload,
        'payload': payload,
      });
      _channel!.sink.add(msg);
    }
  }

  /// Disposes of the active WebSocket connection and pending timers.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channelSub?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
