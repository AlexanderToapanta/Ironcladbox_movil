import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  final _secureStorage = const FlutterSecureStorage();
  io.Socket? _socket;
  bool _connected = false;
  final Map<String, List<Function(dynamic)>> _listeners = {};

  final _connectionController = StreamController<bool>.broadcast();
  final _reconnectController = StreamController<void>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<void> get onReconnected => _reconnectController.stream;
  bool get isConnected => _connected;

  factory SocketService() => _instance;
  SocketService._internal();

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) return;

    _socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setQuery({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      _connectionController.add(true);
      _reconnectController.add(null);
      print('Socket conectado: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      _connected = false;
      _connectionController.add(false);
      print('Socket desconectado: $reason');
    });

    _socket!.onConnectError((error) {
      _connected = false;
      _connectionController.add(false);
      print('Socket error: $error');
    });

    _bindStoredListeners();
    _socket!.connect();
  }

  void _bindStoredListeners() {
    if (_socket == null) return;
    for (final entry in _listeners.entries) {
      _socket!.on(entry.key, (data) {
        for (final cb in entry.value) {
          cb(data);
        }
      });
    }
  }

  void on(String event, Function(dynamic) callback) {
    _listeners.putIfAbsent(event, () => []);
    _listeners[event]!.add(callback);
    _socket?.on(event, (data) {
      for (final cb in _listeners[event] ?? []) {
        cb(data);
      }
    });
  }

  void off(String event, [Function(dynamic)? callback]) {
    if (callback != null) {
      _listeners[event]?.remove(callback);
    } else {
      _listeners.remove(event);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
    _listeners.clear();
    _connectionController.add(false);
  }
}
