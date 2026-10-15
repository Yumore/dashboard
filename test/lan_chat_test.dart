import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/chat/lan_chat_client.dart';
import 'package:dashboard/features/chat/lan_chat_controller.dart';
import 'package:dashboard/features/chat/lan_chat_message.dart';
import 'package:dashboard/features/chat/lan_chat_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'real WebSocket handshake, roster, JSON escaping and reconnect work',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final sockets = <WebSocket>[];
      final received = StreamController<Map<String, dynamic>>.broadcast();
      server.listen((request) async {
        expect(request.uri.path, '/webchat/echo');
        expect(request.headers.value('device'), 'desktop');
        final socket = await WebSocketTransformer.upgrade(request);
        sockets.add(socket);
        socket.add(
          jsonEncode({
            'currentUserId': 's1',
            'currentUserName': 'alice',
            'userList': ['alice', 'bob'],
            'count': 2,
          }),
        );
        socket.listen((event) {
          received.add(jsonDecode(event as String) as Map<String, dynamic>);
          socket.add(event);
        });
      });
      final client = LanChatClient();
      addTearDown(() async {
        await client.dispose();
        for (final socket in sockets) {
          await socket.close();
        }
        await server.close(force: true);
        await received.close();
      });
      final uri = Uri.parse('ws://127.0.0.1:${server.port}/webchat');
      final rosterFuture = client.rosters.first;
      await client.connect(uri, 'desktop');
      final roster = await rosterFuture;
      expect(roster.user, 'alice');
      expect(roster.peers, ['bob']);
      final receiveFuture = received.stream.first;
      final echoFuture = client.messages.first;
      const message = LanChatMessage(
        id: 'm1',
        sender: 'alice',
        recipient: 'bob',
        text: '引号"、反斜线\\和换行\n都应保留',
      );
      client.send(message);
      expect((await receiveFuture)['msg'], message.text);
      expect((await echoFuture).text, message.text);
      final nextRoster = client.rosters.first;
      await client.connect(uri, 'desktop');
      expect((await nextRoster).peers, ['bob']);
      expect(sockets.length, 2);
      expect(sockets.first.readyState, isNot(WebSocket.open));
      final afterReconnect = received.stream.first;
      client.send(message);
      expect((await afterReconnect)['msgId'], 'm1');
      await client.disconnect();
      expect(() => client.send(message), throwsStateError);
    },
  );

  test(
    'keeps last 100 messages and isolates servers, users and peers',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = LanChatStore();
      final messages = List.generate(
        101,
        (index) => LanChatMessage(
          id: '$index',
          sender: 'alice',
          recipient: 'bob',
          text: '$index',
        ),
      );
      await store.save('ws://server-a', 'alice', 'bob', messages);
      final history = await store.load('ws://server-a', 'alice', 'bob');
      expect(history.length, 100);
      expect(history.first.id, '1');
      expect(await store.load('ws://server-b', 'alice', 'bob'), isEmpty);
      expect(await store.load('ws://server-a', 'eve', 'bob'), isEmpty);
      await store.clear('ws://server-a', 'alice', 'bob');
      expect(await store.load('ws://server-a', 'alice', 'bob'), isEmpty);
    },
  );

  test(
    'incoming messages update unread counts and echoed sends are not duplicated',
    () async {
      SharedPreferences.setMockInitialValues({});
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final socketReady = Completer<WebSocket>();
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        socketReady.complete(socket);
        socket.add(
          jsonEncode({
            'currentUserId': 's1',
            'currentUserName': 'alice',
            'userList': ['alice', 'bob'],
          }),
        );
        socket.listen(socket.add);
      });
      final client = LanChatClient();
      final controller = LanChatController(client: client);
      addTearDown(() async {
        await controller.disconnect();
        controller.dispose();
        if (socketReady.isCompleted) await (await socketReady.future).close();
        await server.close(force: true);
      });
      final rosterReady = changesUntil(
        controller,
        () => controller.roster != null,
      );
      await controller.connect(
        Uri.parse('ws://127.0.0.1:${server.port}'),
        'desktop',
      );
      await rosterReady;
      final incoming = const LanChatMessage(
        id: 'incoming-1',
        sender: 'bob',
        recipient: 'alice',
        text: '你好',
      ).encode();
      final unreadReady = changesUntil(
        controller,
        () => controller.unread('bob') == 1,
      );
      final socket = await socketReady.future;
      socket.add(incoming);
      socket.add(incoming);
      await unreadReady;
      await controller.openPeer('bob');
      expect(controller.unread('bob'), 0);
      expect(controller.messages('bob').length, 1);
      final echoed = client.messages.first;
      await controller.send('bob', '回复');
      await echoed;
      await controller.openPeer('bob');
      expect(controller.messages('bob').length, 2);
      await controller.clearPeer('bob');
      expect(controller.messages('bob'), isEmpty);
    },
  );
}

Future<void> changesUntil(
  LanChatController controller,
  bool Function() condition,
) async {
  final completer = Completer<void>();
  void listener() {
    if (condition() && !completer.isCompleted) completer.complete();
  }

  controller.addListener(listener);
  listener();
  try {
    await completer.future.timeout(const Duration(seconds: 5));
  } finally {
    controller.removeListener(listener);
  }
}
