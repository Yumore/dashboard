import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/chat/lan_chat_message.dart';
import 'package:dashboard/features/chat/lan_chat_roster.dart';

/// The flutter-im /echo protocol, with one socket subscription per connection.
class LanChatClient {
  final _rosters = StreamController<LanChatRoster>.broadcast();
  final _messages = StreamController<LanChatMessage>.broadcast();
  final _errors = StreamController<String>.broadcast();
  final _connections = StreamController<bool>.broadcast();
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  int _generation = 0;
  bool _disposed = false;

  Stream<LanChatRoster> get rosters => _rosters.stream;
  Stream<LanChatMessage> get messages => _messages.stream;
  Stream<String> get errors => _errors.stream;
  Stream<bool> get connections => _connections.stream;
  bool get connected => _socket?.readyState == WebSocket.open;

  Future<void> connect(Uri endpoint, String device) async {
    if (_disposed) throw StateError('连接已释放');
    if (!['ws', 'wss'].contains(endpoint.scheme) || endpoint.host.isEmpty) {
      throw const FormatException('请输入完整的 ws:// 或 wss:// 服务地址');
    }
    if (device.isEmpty || !RegExp(r'^[\x20-\x7e]+$').hasMatch(device)) {
      throw const FormatException('设备标识请使用英文或数字');
    }
    await disconnect();
    final generation = _generation;
    final path = endpoint.path.replaceFirst(RegExp(r'/+$'), '');
    final uri = endpoint.replace(
      path: path.endsWith('/echo') ? path : '$path/echo',
    );
    final attempt = WebSocket.connect(
      uri.toString(),
      headers: {'device': device},
    );
    late final WebSocket socket;
    try {
      socket = await attempt.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      unawaited(
        attempt.then<void>((lateSocket) async {
          await lateSocket.close();
        }, onError: (Object _) {}),
      );
      rethrow;
    }
    if (_disposed || generation != _generation) {
      await socket.close();
      return;
    }
    _socket = socket;
    _connections.add(true);
    _subscription = socket.listen(
      _receive,
      onError: (Object error) {
        if (!_disposed && generation == _generation) _errors.add('$error');
      },
      onDone: () {
        if (!_disposed && generation == _generation) {
          _socket = null;
          _connections.add(false);
        }
      },
    );
  }

  void _receive(dynamic event) {
    try {
      final text = event is String ? event : utf8.decode(event as List<int>);
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) throw const FormatException('消息格式错误');
      if (json.containsKey('userList')) {
        _rosters.add(LanChatRoster.fromJson(json));
      } else {
        final message = LanChatMessage.fromJson(json);
        if (message.sender.isEmpty || message.id.isEmpty) {
          throw const FormatException('消息缺少发送者或消息 ID');
        }
        _messages.add(message);
      }
    } catch (error) {
      _errors.add('$error');
    }
  }

  void send(LanChatMessage message) {
    if (!connected) throw StateError('聊天连接已断开');
    _socket!.add(message.encode());
  }

  Future<void> disconnect() async {
    _generation++;
    final socket = _socket;
    _socket = null;
    await _subscription?.cancel();
    _subscription = null;
    await socket?.close();
    if (!_disposed) _connections.add(false);
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await Future.wait([
      _rosters.close(),
      _messages.close(),
      _errors.close(),
      _connections.close(),
    ]);
  }
}
