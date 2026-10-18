import 'package:dashboard/features/chat/messenger_demo/messenger_call_model.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_chat_model.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_story_model.dart';
import 'package:dashboard/features/chat/chat_module_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_demo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Messenger source demo data remains complete', () {
    expect(chatMockData, hasLength(21));
    expect(callMockData, hasLength(9));
    expect(storiesMockData, hasLength(15));
    expect(chatMockData.first.name, 'Abhishek');
    expect(callMockData.first.callSource, 'video');
    expect(storiesMockData.first.name, 'My Story');
  });

  testWidgets('Messenger five tabs preserve the source UI flows', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MessengerDemoPage()));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Where are you ?'), findsOneWidget);

    await tester.tap(find.text('Calls').last);
    await tester.pumpAndSettle();
    expect(find.text('Mom'), findsOneWidget);

    for (final label in ['Camera', 'Stories', 'Contacts']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text('$label screen'), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat module opens the migrated Messenger demo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ChatModulePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Messenger 本地界面演示'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you ?'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat module menu exposes the full WeChat demo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: ChatModulePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('更多本地界面演示'));
    await tester.pumpAndSettle();
    expect(find.text('微信全量界面演示'), findsOneWidget);
    await tester.ensureVisible(find.text('微信全量界面演示'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('微信全量界面演示'));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterWechatFullDemoPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
