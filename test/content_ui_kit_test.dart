import 'package:dashboard/features/content_hub/content_hub_page.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:dashboard/features/reading/reading_module_page.dart';
import 'package:dashboard/features/shared/ui/content_entry_card.dart';
import 'package:dashboard/features/shared/ui/content_entry_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('entry grid uses a width driven column count', () {
    expect(ContentEntryGrid.columnsFor(359), 1);
    expect(ContentEntryGrid.columnsFor(360), 2);
    expect(ContentEntryGrid.columnsFor(420), 2);
    expect(ContentEntryGrid.columnsFor(619), 2);
    expect(ContentEntryGrid.columnsFor(620), 3);
    expect(ContentEntryGrid.columnsFor(900), 4);
  });

  testWidgets('hub renders one card per module and opens a module page', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ContentHubPage()));
    await tester.pumpAndSettle();
    expect(find.text('内容模块'), findsOneWidget);
    expect(find.byType(ContentEntryCard), findsNWidgets(8));
    await tester.tap(find.text('阅读'));
    await tester.pumpAndSettle();
    expect(find.byType(ReadingModulePage), findsOneWidget);
    expect(find.text('书源与书库'), findsOneWidget);
    expect(find.text('找书与检索'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('module tabs keep migrated entries off the app bar', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MovieModulePage()));
    await tester.pumpAndSettle();
    expect(find.text('入口'), findsOneWidget);
    expect(find.text('发现'), findsOneWidget);
    expect(find.text('片单'), findsOneWidget);
    expect(find.byTooltip('inKino · Finnkino 场次'), findsOneWidget);
    expect(find.byType(ContentEntryCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
