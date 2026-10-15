import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_config_store.dart';
import 'package:dashboard/features/crawler/crawl_exporter.dart';
import 'package:dashboard/features/crawler/crawl_page_data.dart';
import 'package:dashboard/features/crawler/crawl_state.dart';
import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('stopping during demo logging stops further callbacks', () async {
    final task = CrawlTask(CrawlConfig.presets.first);
    task.addListener(() {
      if (task.logs.length == 2) task.stop();
    });
    await task.start();
    expect(task.logs.length, 3);
    expect(task.state, CrawlState.stopped);
    task.dispose();
  });

  const config = CrawlConfig(
    id: 'test',
    name: '测试',
    url: 'https://example.test/',
  );
  final page = CrawlPageData('<a href="/one">新闻</a>', config.uri);

  test(
    'pause holds fetched results until resume; start cannot run twice',
    () async {
      final fetched = Completer<CrawlPageData>();
      var calls = 0;
      final task = CrawlTask(
        config,
        fetch: (_, _) {
          calls++;
          return fetched.future;
        },
      );
      addTearDown(task.dispose);
      final run = task.start();
      await task.start();
      task.pause();
      fetched.complete(page);
      await Future<void>.delayed(Duration.zero);
      expect(task.state, CrawlState.paused);
      expect(task.items, isEmpty);
      task.config = config.edited(
        url: config.url,
        selector: '.changed',
        encoding: 'utf-8',
      );
      task.resume();
      await run;
      expect(calls, 1);
      expect(task.state, CrawlState.completed);
      expect(task.items.single.title, '新闻');
    },
  );

  test(
    'stopped and disposed generations cannot commit late results or errors',
    () async {
      final old = Completer<CrawlPageData>();
      CancelToken? oldToken;
      var calls = 0;
      final task = CrawlTask(
        config,
        fetch: (_, token) {
          if (calls++ == 0) {
            oldToken = token;
            return old.future;
          }
          return Future.value(page);
        },
      );
      final first = task.start();
      task.pause();
      task.stop();
      expect(oldToken!.isCancelled, isTrue);
      await task.start();
      old.completeError(StateError('stale error'));
      await first;
      expect(task.state, CrawlState.completed);
      expect(task.items.length, 1);
      task.dispose();

      final waiting = Completer<CrawlPageData>();
      final disposed = CrawlTask(config, fetch: (_, _) => waiting.future);
      final run = disposed.start();
      disposed.pause();
      disposed.dispose();
      waiting.complete(page);
      await run;
      expect(disposed.items, isEmpty);
    },
  );

  test(
    'failures surface and a subsequent run recovers; logs are bounded',
    () async {
      var fail = true;
      final task = CrawlTask(
        config,
        fetch: (_, _) async {
          if (fail) throw StateError('offline');
          return page;
        },
      );
      addTearDown(task.dispose);
      await task.start();
      expect(task.state, CrawlState.failed);
      expect(task.logs.last.level, 'error');
      fail = false;
      await task.start();
      for (var index = 0; index < 600; index++) {
        await task.start();
      }
      expect(task.logs.length, 1024);
      task.clearLogs();
      expect(task.logs, isEmpty);
    },
  );

  test(
    'configuration is namespaced, restores safely and exports real JSON files',
    () async {
      SharedPreferences.setMockInitialValues({'unrelated': 'preserved'});
      final store = CrawlConfigStore();
      final edited = config.edited(
        url: 'https://example.test/new',
        selector: '.entry a',
        encoding: 'gbk',
      );
      await store.save(edited);
      expect((await store.load(config)).selector, '.entry a');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('unrelated'), 'preserved');
      await prefs.setString('content.crawler.v1.test', '{broken');
      expect(await store.load(config), same(config));
      await prefs.setInt('content.crawler.v1.test', 7);
      expect(await store.load(config), same(config));

      final directory = await Directory.systemTemp.createTemp(
        'dashboard-crawler-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final exporter = CrawlExporter(directory: () async => directory);
      final task = CrawlTask(config, fetch: (_, _) async => page);
      addTearDown(task.dispose);
      await task.start();
      for (final kind in ['config', 'logs', 'results']) {
        final file = await exporter.save(task, kind);
        expect(
          jsonDecode(await file.readAsString()),
          jsonDecode(exporter.encode(task, kind)),
        );
        expect(
          file.path.startsWith('${directory.path}/content_crawler/test/'),
          isTrue,
        );
      }
      expect(() => exporter.encode(task, '../bad'), throwsArgumentError);
      final delayedDirectory = Completer<Directory>();
      final delayedExporter = CrawlExporter(
        directory: () => delayedDirectory.future,
      );
      final saving = delayedExporter.save(task, 'config');
      task.config = const CrawlConfig(id: '../../escape', name: 'bad');
      delayedDirectory.complete(directory);
      final saved = await saving;
      expect(
        saved.path.startsWith('${directory.path}/content_crawler/test/'),
        isTrue,
      );
      expect(jsonDecode(await saved.readAsString())['url'], config.url);
      await expectLater(exporter.save(task, 'config'), throwsFormatException);
    },
  );
}
