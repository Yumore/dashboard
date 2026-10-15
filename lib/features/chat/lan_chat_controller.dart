import 'dart:async';

import 'package:dashboard/features/chat/lan_chat_client.dart';
import 'package:dashboard/features/chat/lan_chat_message.dart';
import 'package:dashboard/features/chat/lan_chat_roster.dart';
import 'package:dashboard/features/chat/lan_chat_store.dart';
import 'package:flutter/foundation.dart';

class LanChatController extends ChangeNotifier {
  LanChatController({LanChatClient? client, LanChatStore? store})
    : _client = client ?? LanChatClient(),
      store = store ?? LanChatStore() {
    _subscriptions.add(
      _client.rosters.listen((value) {
        if (_roster?.user != value.user) {
          _history.clear();
          _unread.clear();
        }
        _roster = value;
        _notify();
      }),
    );
    _subscriptions.add(
      _client.messages.listen((message) {
        final user = _roster?.user;
        final endpoint = _endpoint;
        if (user == null) return;
        _queue = _queue
            .then((_) => _record(message, user, endpoint))
            .catchError((Object error) {
              _error = '$error';
              _notify();
            });
      }),
    );
    _subscriptions.add(
      _client.errors.listen((error) {
        _error = error;
        _notify();
      }),
    );
    _subscriptions.add(
      _client.connections.listen((connected) {
        if (!connected) _roster = null;
        _notify();
      }),
    );
  }

  final LanChatClient _client;
  final LanChatStore store;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<String, List<LanChatMessage>> _history = {};
  final Map<String, int> _unread = {};
  Future<void> _queue = Future.value();
  LanChatRoster? _roster;
  String _endpoint = '';
  String? _activePeer;
  String? _error;
  bool _connecting = false;
  bool _disposed = false;

  LanChatRoster? get roster => _roster;
  String? get error => _error;
  bool get connecting => _connecting;
  bool get connected => _client.connected;
  int unread(String peer) => _unread[peer] ?? 0;
  List<LanChatMessage> messages(String peer) =>
      List.unmodifiable(_history[peer] ?? []);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> connect(Uri endpoint, String device) async {
    if (_connecting) return;
    _connecting = true;
    _error = null;
    _notify();
    try {
      await disconnect();
      _endpoint = endpoint.toString();
      _history.clear();
      _unread.clear();
      await store.saveSettings(_endpoint, device);
      await _client.connect(endpoint, device);
    } catch (error) {
      _error = '$error';
    } finally {
      _connecting = false;
      _notify();
    }
  }

  Future<void> disconnect() async {
    await _queue;
    await _client.disconnect();
    _roster = null;
    _activePeer = null;
    _notify();
  }

  Future<void> openPeer(String peer) async {
    final self = _roster?.user;
    if (self == null) return;
    final endpoint = _endpoint;
    final operation = _queue.then((_) async {
      final messages = await store.load(endpoint, self, peer);
      if (_endpoint != endpoint || _roster?.user != self) return;
      _history[peer] = messages;
      _activePeer = peer;
      _unread.remove(peer);
      _notify();
    });
    _queue = operation.catchError((Object error) {
      _error = '$error';
      _notify();
    });
    await operation;
  }

  void closePeer() {
    _activePeer = null;
  }

  Future<void> _record(
    LanChatMessage message,
    String self,
    String endpoint,
  ) async {
    if (message.sender != self && message.recipient != self) return;
    final peer = message.sender == self ? message.recipient : message.sender;
    final currentSession = _endpoint == endpoint && _roster?.user == self;
    final history =
        (currentSession ? _history[peer] : null) ??
        await store.load(endpoint, self, peer);
    if (history.any(
      (saved) => saved.id == message.id && saved.sender == message.sender,
    )) {
      return;
    }
    history.add(message);
    if (history.length > 100) history.removeRange(0, history.length - 100);
    await store.save(endpoint, self, peer, history);
    if (_endpoint != endpoint || _roster?.user != self) return;
    _history[peer] = history;
    if (message.sender != self && _activePeer != peer) {
      _unread[peer] = unread(peer) + 1;
    }
    _notify();
  }

  Future<void> send(String peer, String text) async {
    final self = _roster;
    if (self == null || !_client.connected) throw StateError('请先连接聊天服务');
    if (text.trim().isEmpty) return;
    final message = LanChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sender: self.user,
      recipient: peer,
      text: text,
      sessionId: self.sessionId,
    );
    _client.send(message);
    final endpoint = _endpoint;
    final operation = _queue.then((_) => _record(message, self.user, endpoint));
    _queue = operation.catchError((Object error) {
      _error = '$error';
      _notify();
    });
    await operation;
  }

  Future<void> clearPeer(String peer) async {
    final self = _roster?.user;
    if (self == null) return;
    final endpoint = _endpoint;
    final operation = _queue.then((_) async {
      await store.clear(endpoint, self, peer);
      if (_endpoint == endpoint && _roster?.user == self) {
        _history[peer] = [];
        _notify();
      }
    });
    _queue = operation.catchError((Object error) {
      _error = '$error';
      _notify();
    });
    await operation;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_client.dispose());
    super.dispose();
  }
}
