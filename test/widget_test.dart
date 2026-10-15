// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dashboard/features/content_hub/content_hub_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('content hub exposes every migrated module', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: ContentHubPage()));

    for (final module in ['阅读', '小说', '动漫', '漫画', '影视', '聊天', '直播', '爬虫']) {
      await tester.scrollUntilVisible(find.text(module), 180);
      expect(find.text(module), findsOneWidget);
    }
    await tester.tap(find.text('直播'));
    await tester.pumpAndSettle();

    expect(find.text('直播订阅'), findsOneWidget);
    expect(find.text('M3U / TXT 订阅地址'), findsOneWidget);
  });
}
