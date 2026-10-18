import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_basics_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_catalog_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_material_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_message.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_message_item.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpDemo(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: FlutterWechatDemoPage()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('sample data is the source data', () {
    test('52 contacts, in the source order', () {
      expect(flutterWechatContacts.length, 52);
      expect(flutterWechatContacts.first.name, '阿岚');
      expect(flutterWechatContacts.first.seationKey, 'A');
      expect(flutterWechatContacts[2].name, '斌哥');
      expect(flutterWechatContacts[14].name, 'JC');
      expect(flutterWechatContacts[14].avatarUrl, '');
      expect(flutterWechatContacts[22].name, 'Mary');
      expect(flutterWechatContacts[13].name, '姬如雪');
      expect(flutterWechatContacts[17].name, '留学生');
      expect(flutterWechatContacts.last.name, '=github');
      expect(flutterWechatContacts.last.seationKey, '#');
    });

    test('10 conversations, in the source order', () {
      expect(flutterWechatMessages.length, 10);
      expect(
        flutterWechatMessages.map((FlutterWechatMessage m) => m.title).toList(),
        <String>[
          '冯宝宝',
          '张楚岚',
          '徐四',
          '张灵玉',
          '夏禾',
          '诸葛青',
          '王也',
          '风莎燕',
          '张之维',
          '陆瑾',
        ],
      );
      expect(flutterWechatMessages.first.subTitle, '你现在在哪里？带带我');
      expect(flutterWechatMessages[1].subTitle, '宝儿姐，别闹！！！');
      expect(flutterWechatMessages[2].subTitle, '赶紧给我回公司开会。。');
      expect(
        flutterWechatMessages.last.subTitle,
        '一百多岁，人称“一生无暇”，三一门唯一幸存者，修炼逆生三重',
      );
      expect(
        flutterWechatMessages.every(
          (FlutterWechatMessage m) => m.type == FlutterWechatMessageType.chat,
        ),
        isTrue,
      );
    });

    test('every bundled image is under the demo asset directory', () {
      expect(FlutterWechatAvailableImages.all.length, 69);
      expect(
        FlutterWechatAvailableImages.all.every(
          (String path) =>
              path.startsWith(FlutterWechatAvailableImages.assetDirectory),
        ),
        isTrue,
      );
    });
  });

  testWidgets('shell shows 微信 and the four source tabs', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    expect(find.text('微信'), findsOneWidget);
    for (final String label in <String>['首页', '通讯录', '发现', '我的']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('冯宝宝'), findsOneWidget);
    expect(find.text('你现在在哪里？带带我'), findsOneWidget);
  });

  testWidgets('tab taps switch to the source pages, keeping state', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    await tester.tap(find.text('通讯录'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
    expect(find.text('新的朋友'), findsOneWidget);
    expect(find.text('阿岚'), findsOneWidget);
    expect(find.text('冯宝宝'), findsNothing);

    await tester.tap(find.text('发现'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);
    expect(find.text('朋友圈'), findsOneWidget);
    expect(find.text('扫一扫'), findsOneWidget);
    expect(find.text('摇一摇'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('小程序'),
      find.byType(ListView).first,
      const Offset(0.0, -200.0),
    );
    expect(find.text('小程序'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 3);
    expect(find.text('Herbie'), findsOneWidget);
    expect(find.text('微信号：NMDFCKDDFY'), findsOneWidget);

    await tester.tap(find.text('首页'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    expect(find.text('冯宝宝'), findsOneWidget);
  });

  testWidgets('contact list scrolls to the # group and keeps its index bar', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);
    await tester.tap(find.text('通讯录'));
    await tester.pump();

    await tester.dragUntilVisible(
      find.text('=github'),
      find.byType(ListView).first,
      const Offset(0.0, -400.0),
    );
    expect(find.text('=github'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('阿岚'),
      find.byType(ListView).first,
      const Offset(0.0, 400.0),
    );
    expect(find.text('阿岚'), findsOneWidget);
  });

  testWidgets('tapping a conversation stays on the list: the source had no '
      'chat thread, only a native toast', (WidgetTester tester) async {
    await pumpDemo(tester);

    await tester.tap(find.text('冯宝宝'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FlutterWechatDemoPage), findsOneWidget);
    expect(find.byType(FlutterWechatSearchPage), findsNothing);
    expect(find.text('冯宝宝'), findsOneWidget);
    expect(find.text('你现在在哪里？带带我'), findsOneWidget);
  });

  testWidgets('conversation rows keep the source order when scrolled', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    final List<String> visibleTitles = tester
        .widgetList<FlutterWechatMessageItem>(
          find.byType(FlutterWechatMessageItem),
        )
        .map((FlutterWechatMessageItem item) => item.message.title)
        .toList();
    expect(visibleTitles.first, '冯宝宝');
    expect(visibleTitles[1], '张楚岚');
    expect(visibleTitles[2], '徐四');

    await tester.dragUntilVisible(
      find.text('陆瑾'),
      find.byType(ListView).first,
      const Offset(0.0, -150.0),
    );
    expect(find.text('陆瑾'), findsOneWidget);
    expect(find.text('一百多岁，人称“一生无暇”，三一门唯一幸存者，修炼逆生三重'), findsOneWidget);
  });

  testWidgets('search opens from the app bar and shows the source labels', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);

    await tester.tap(find.byTooltip('搜索'));
    await settleRoute(tester);

    expect(find.byType(FlutterWechatSearchPage), findsOneWidget);
    expect(find.text('搜索指定文章'), findsOneWidget);
    for (final String label in <String>['朋友圈', '文章', '公众号', '小说', '音乐', '表情']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.byIcon(Icons.chevron_left));
    await settleRoute(tester);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(FlutterWechatSearchPage), findsNothing);
    expect(find.text('微信'), findsOneWidget);
  });

  testWidgets('我 → 钱包 opens the ported Flutter UI catalogue', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);
    await tester.tap(find.text('我的'));
    await tester.pump();

    await tester.tap(find.text('钱包'));
    await settleRoute(tester);

    expect(find.byType(FlutterWechatCatalogPage), findsOneWidget);
    expect(find.text('Flutter UI'), findsOneWidget);
    expect(find.text('基础组件'), findsOneWidget);
    expect(find.text('Material Components'), findsOneWidget);
    expect(find.text('Cupertino(iOS风格的widget)'), findsOneWidget);

    await tester.tap(find.text('基础组件'));
    await settleRoute(tester);
    expect(find.byType(FlutterWechatBasicsPage), findsOneWidget);
    expect(find.text('Container'), findsOneWidget);
    expect(find.text('Row'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(FlutterWechatBasicsPage),
        matching: find.byType(BackButton),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    await tester.tap(find.text('Material Components'));
    await settleRoute(tester);
    expect(find.byType(FlutterWechatMaterialPage), findsOneWidget);
    expect(find.text('App结构和导航'), findsOneWidget);
    expect(find.text('Scaffold'), findsOneWidget);
  });
}
