import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_ai.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_detail_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_entrance.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_list_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_comment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_contacts_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_conversation_model.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_discovery_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_friend.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_marker.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_message.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moment.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_moments_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_reply_chooser.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seeded data', () {
    test('chat entrances keep the source order, text and unread counts', () {
      final List<FakeWechatChatEntrance> entrances =
          FakeWechatSeedData.chatEntrances;

      expect(entrances, hasLength(13));
      expect(
        entrances.map((FakeWechatChatEntrance entry) => entry.name).toList(),
        <String>[
          '梁朝伟',
          '长泽雅美',
          '刘德华',
          '周华健',
          '宇多田光',
          '仓木麻衣',
          '小栗旬',
          '金城武',
          '张卫健',
          '赵本山',
          '新垣结衣',
          '滨崎步',
          '林青霞',
        ],
      );

      expect(entrances.first.unreadCount, 3);
      expect(entrances.first.recentMessage.text, '一起拍电影吧');
      expect(entrances.first.recentMessage.timestamp, 1000000000);
      expect(entrances[1].recentMessage.timestamp, 100000000);
      expect(entrances.last.unreadCount, 10);
      expect(entrances.last.recentMessage.text, '还记得我的电影吗？');
      expect(entrances.last.recentMessage.timestamp, isNull);
    });

    test(
      'total unread is 123 while the header keeps the source literal 130',
      () {
        expect(
          FakeWechatSeedData.chatEntrances.fold<int>(
            0,
            (int sum, FakeWechatChatEntrance entry) => sum + entry.unreadCount,
          ),
          123,
        );
        expect(FakeWechatSeedData.totalUnread, 123);
        expect(FakeWechatDemoConfig.chatHeaderTitle, '微信(130)');
        expect(FakeWechatDemoConfig.headerUnreadLiteral, 130);
        expect(FakeWechatSeedData.chatEntrances[1].unreadLabel, '10');
      },
    );

    test('contacts carry the source letter order and 13 friends', () {
      expect(FakeWechatSeedData.contactLetterHeaders, <String>[
        'B',
        'C',
        'L',
        'J',
        'X',
        'Y',
        'Z',
      ]);
      expect(FakeWechatSeedData.contactsItems, hasLength(21));
      expect(FakeWechatSeedData.contactsItems.last, 13);
      expect(
        FakeWechatSeedData.contactsItems
            .whereType<FakeWechatFriend>()
            .map((FakeWechatFriend friend) => friend.name)
            .toList(),
        <String>[
          '滨崎步',
          '长泽雅美',
          '仓木麻衣',
          '梁朝伟',
          '刘德华',
          '林青霞',
          '金城武',
          '小栗旬',
          '新垣结衣',
          '宇多田光',
          '周华健',
          '张卫健',
          '赵本山',
        ],
      );
    });

    test('moments keep the seven source entries and their comments', () {
      final List<FakeWechatMoment> moments = FakeWechatSeedData.moments;
      expect(moments, hasLength(7));
      expect(
        moments.map((FakeWechatMoment moment) => moment.type).toList(),
        <int>[4, 4, 1, 3, 3, 3, 2],
      );
      expect(moments[0].text, '我喜欢的一首歌');
      expect(moments[0].audioLink?.name, '回忆沙漠');
      expect(moments[0].audioLink?.artist, '杨宗纬');
      expect(moments[1].audioLink?.name, '你不是真正的快乐');
      expect(moments[2].friend.name, '仓木麻衣');
      expect(moments[3].webPageLink?.title, '网易绝情踢员工');
      expect(moments[6].images, hasLength(3));
      expect(
        moments[6].comments
            .map((FakeWechatComment comment) => comment.text)
            .toList(),
        <String>['好样的', '你是个人才', '你才是个人才'],
      );
      expect(moments[6].comments.last.replyer?.name, '长泽雅美');
    });
  });

  group('AI reply rules', () {
    test('chooser applies seed then sequence modulo reply count', () {
      const FakeWechatReplyChooser chooser = FakeWechatReplyChooser(
        replies: <String>['a', 'b', 'c'],
        seed: 1,
      );

      expect(chooser.replyFor(0), 'b');
      expect(chooser.replyFor(1), 'c');
      expect(chooser.replyFor(2), 'a');
      expect(chooser.replyFor(3), 'b');
    });

    test('default chooser and empty chooser both yield the source literal', () {
      const FakeWechatReplyChooser defaults = FakeWechatReplyChooser();
      const FakeWechatReplyChooser empty = FakeWechatReplyChooser(
        replies: <String>[],
      );

      expect(defaults.replyFor(0), 'my reply');
      expect(defaults.replyFor(9), 'my reply');
      expect(empty.replyFor(3), 'my reply');
    });

    testWidgets('AI keeps the source 10 second cadence and literal reply', (
      WidgetTester tester,
    ) async {
      final List<String> received = <String>[];
      final FakeWechatChatAi ai = FakeWechatChatAi();
      ai.start(received.add);

      await tester.pump(const Duration(seconds: 9));
      expect(received, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      expect(received, <String>['my reply']);

      ai.dispose();
    });

    testWidgets('AI cycles through the injected chooser in order', (
      WidgetTester tester,
    ) async {
      final List<String> received = <String>[];
      final FakeWechatChatAi ai = FakeWechatChatAi(
        replyInterval: const Duration(seconds: 1),
        chooser: const FakeWechatReplyChooser(
          replies: <String>['一', '二', '三'],
          seed: 0,
        ),
      );
      ai.start(received.add);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(received, <String>['一', '二', '三', '一']);
      expect(ai.sequence, 4);
      ai.dispose();
    });
  });

  group('conversation append ordering', () {
    test('sendText appends a marker before the outgoing message', () {
      final DateTime fixed = DateTime.utc(2026, 10, 18, 12, 34, 56);
      final FakeWechatConversationModel conversation =
          FakeWechatConversationModel(
            friend: FakeWechatSeedData.friends[2],
            now: () => fixed,
          );

      final List<Object> added = conversation.sendText('你好');

      expect(conversation.items, hasLength(2));
      expect(conversation.items.first, isA<FakeWechatMarker>());
      expect(conversation.items.last, isA<FakeWechatMessage>());
      expect(
        (conversation.items.first as FakeWechatMarker).text,
        fixed.toString(),
      );
      expect(conversation.items.first, same(added.first));
      expect(conversation.items.last, same(added.last));

      final FakeWechatMessage outgoing =
          conversation.items.last as FakeWechatMessage;
      expect(outgoing.type, FakeWechatMessage.textType);
      expect(outgoing.text, '你好');
      expect(identical(outgoing.sender, FakeWechatSeedData.user), isTrue);
    });

    test('reply appends one friend message and defaults to FRIENDS[0]', () {
      final FakeWechatConversationModel conversation =
          FakeWechatConversationModel(friend: FakeWechatSeedData.friends[2]);

      conversation.sendText('first');
      conversation.appendReply('my reply');

      expect(conversation.items, hasLength(3));
      expect(conversation.messageCount, 2);
      final FakeWechatMessage reply =
          conversation.items.last as FakeWechatMessage;
      expect(reply.text, 'my reply');
      expect(identical(reply.sender, FakeWechatSeedData.friends[0]), isTrue);
      expect(conversation.items.whereType<FakeWechatMarker>(), hasLength(1));

      conversation.dispose();
    });
  });

  group('widget flows', () {
    testWidgets('chat list shows badges and switches through all four tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FakeWechatDemoPage()));
      await tester.pumpAndSettle();

      expect(find.text('微信(130)'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('10'), findsWidgets);
      expect(find.byType(FakeWechatChatListPage), findsOneWidget);

      await tester.tap(find.text('联系人'));
      await tester.pumpAndSettle();
      expect(find.text('滨崎步'), findsOneWidget);
      expect(find.text('B'), findsWidgets);

      await tester.drag(
        find.descendant(
          of: find.byType(FakeWechatContactsPage),
          matching: find.byType(ListView),
        ),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(find.text('13位联系人'), findsOneWidget);

      await tester.tap(find.text('发现'));
      await tester.pumpAndSettle();
      expect(find.text('朋友圈'), findsOneWidget);

      await tester.tap(find.text('我'));
      await tester.pumpAndSettle();
      expect(find.text('廖布斯'), findsOneWidget);
      expect(find.text(FakeWechatDemoConfig.profileSignature), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('discovery row opens the seeded moments feed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: FakeWechatDiscoveryPage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('朋友圈'));
      await tester.pumpAndSettle();

      expect(find.byType(FakeWechatMomentsPage), findsOneWidget);
      expect(find.text('我喜欢的一首歌'), findsOneWidget);
      expect(find.text('分享一首好听的歌'), findsOneWidget);
      expect(find.text(FakeWechatDemoConfig.momentsTimeLabel), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('tapping a chat opens its conversation page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FakeWechatDemoPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('梁朝伟'));
      await tester.pumpAndSettle();

      expect(find.byType(FakeWechatChatDetailPage), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('梁朝伟')),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('sending text appends the user bubble then the AI reply', (
      WidgetTester tester,
    ) async {
      final FakeWechatChatAi ai = FakeWechatChatAi(
        replyInterval: const Duration(seconds: 3),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: FakeWechatChatDetailPage(
            friend: FakeWechatSeedData.friends[2],
            ai: ai,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '今晚一起吃饭');
      await tester.pump();
      expect(find.text('发 送'), findsOneWidget);

      await tester.tap(find.text('发 送'));
      await tester.pumpAndSettle();
      expect(find.text('今晚一起吃饭'), findsOneWidget);
      expect(find.text('my reply'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('my reply'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('record affordance reports the missing flutter_sound state', (
      WidgetTester tester,
    ) async {
      final FakeWechatChatAi ai = FakeWechatChatAi(
        replyInterval: const Duration(hours: 1),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: FakeWechatChatDetailPage(
            friend: FakeWechatSeedData.friends[0],
            ai: ai,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_voice));
      await tester.pumpAndSettle();
      expect(find.text(FakeWechatDemoConfig.voiceHoldLabel), findsOneWidget);

      await tester.tap(find.text(FakeWechatDemoConfig.voiceHoldLabel));
      await tester.pumpAndSettle();
      expect(
        find.text(FakeWechatDemoConfig.recorderUnavailableMessage),
        findsOneWidget,
      );
      expect(
        FakeWechatDemoConfig.recorderUnavailableMessage,
        '录音不可用（宿主缺少 flutter_sound）',
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
