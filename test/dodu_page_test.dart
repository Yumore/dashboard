import 'package:dashboard/features/reading/dodu_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'DoDu implements its three local tabs and empty bookshelf refresh',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DoduPage()));
      await tester.pump();
      expect(find.text('暂无书籍'), findsOneWidget);
      await tester.drag(find.text('暂无书籍'), const Offset(0, 280));
      await tester.pumpAndSettle();
      expect(find.text('暂无书籍'), findsOneWidget);

      await tester.tap(find.text('书城'));
      await tester.pump();
      expect(find.text('DoDu · 书城'), findsOneWidget);
      await tester.tap(find.text('我的'));
      await tester.pump();
      expect(find.text('DoDu · 我的'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
