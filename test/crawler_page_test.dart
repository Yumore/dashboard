import 'dart:async';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_config_store.dart';
import 'package:dashboard/features/crawler/crawl_page_data.dart';
import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:dashboard/features/crawler/crawl_task_page.dart';
import 'package:dashboard/features/crawler/crawler_module_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('crawler lists configured sources without starting requests', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CrawlerModulePage()));
    await tester.pumpAndSettle();
    expect(find.text('IT之家热点'), findsOneWidget);
    expect(find.textContaining('未开始'), findsNWidgets(4));
    await tester.tap(find.text('本地日志演示'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存并开始'));
    await tester.pumpAndSettle(const Duration(milliseconds: 30));
    expect(find.text('状态：已完成'), findsOneWidget);
    await tester.tap(find.byTooltip('清空日志'));
    await tester.pump();
    expect(find.text('任务日志（0）'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('已完成'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task UI pauses results, resumes and detaches when closed', (
    tester,
  ) async {
    const config = CrawlConfig(
      id: 'test',
      name: '测试',
      url: 'https://example.test',
    );
    final pending = Completer<CrawlPageData>();
    final task = CrawlTask(config, fetch: (_, _) => pending.future);
    addTearDown(task.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: CrawlTaskPage(task: task, store: CrawlConfigStore()),
      ),
    );
    await tester.tap(find.text('保存并开始'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('暂停'));
    await tester.pump();
    pending.complete(CrawlPageData('<a href="/news">采集新闻</a>', config.uri));
    await tester.pump();
    expect(find.text('状态：已暂停'), findsOneWidget);
    expect(find.text('采集新闻'), findsNothing);
    await tester.tap(find.text('继续'));
    await tester.pumpAndSettle();
    expect(find.text('状态：已完成'), findsOneWidget);
    expect(find.text('采集新闻'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    task.clearLogs();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
