import 'dart:convert';

import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_cache.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_parser.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_catalog_repository.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_env.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_playback_controller.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_playlist_type.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_settings_store.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _m3uFixture = '''
#EXTM3U x-tvg-url="https://epg.example.com/guide.xml"
#EXTINF:-1 tvg-id="cctv1" tvg-logo="https://img.example.com/cctv1.png" group-title="央视",CCTV-1 综合
http://live.example.com/cctv1.m3u8
#EXTINF:-1 tvg-name="CCTV-2" group-title="央视",CCTV-2 财经
http://live.example.com/cctv2.m3u8
http://live.example.com/cctv2-backup.m3u8
#EXTINF:-1 group-title="卫视",湖南卫视
rtsp://live.example.com/hunan
#EXTINF:-1,无分组频道
http://live.example.com/other.m3u8
''';

const _txtFixture = '''
央视,#genre#
CCTV-1 综合,http://live.example.com/cctv1.m3u8
CCTV-2 财经,http://live.example.com/cctv2.m3u8
卫视,#genre#
湖南卫视,http://live.example.com/hunan-a.m3u8#http://live.example.com/hunan-b.m3u8
''';

const _uaFixture = '''
#EXTM3U
#UA-Hint Mozilla/5.0 (Linux; Android 13) ExoPlayerLib/2.18.0
#EXTINF:-1,频道
http://live.example.com/ua.m3u8
''';

class _FakeRepository extends EasyTvCatalogRepository {
  _FakeRepository(this.catalog);

  final EasyTvCatalog catalog;

  @override
  Future<EasyTvCatalog> load(String link) async => catalog;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const parser = EasyTvCatalogParser();

  group('EasyTvCatalogParser m3u', () {
    late EasyTvCatalog catalog;

    setUp(() => catalog = parser.parse(_m3uFixture));

    test('detects the m3u dialect and the EPG URL', () {
      expect(catalog.type, EasyTvPlaylistType.m3u);
      expect(catalog.epgUrl, 'https://epg.example.com/guide.xml');
      expect(catalog.uaHint, '');
    });

    test('keeps group order of first appearance, default group last', () {
      expect(catalog.groupNames, ['央视', '卫视', '默认']);
      expect(catalog.groups[0].channels.length, 2);
      expect(catalog.groups[1].channels.length, 1);
      expect(catalog.groups[2].channels.length, 1);
      expect(catalog.channelCount, 4);
    });

    test('numbers channels globally and records coordinates', () {
      expect(
        catalog.channels.map((channel) => channel.title).toList(),
        ['CCTV-1 综合', 'CCTV-2 财经', '湖南卫视', '无分组频道'],
      );
      expect(catalog.channels.map((channel) => channel.serialNum).toList(), [1, 2, 3, 4]);
      expect(catalog.channels[1].groupIndex, 0);
      expect(catalog.channels[1].channelIndex, 1);
      expect(catalog.channels[2].groupIndex, 1);
      expect(catalog.channels[2].channelIndex, 0);
      expect(catalog.channels[3].groupIndex, 2);
      expect(catalog.channelBySerial(3)?.title, '湖南卫视');
      expect(catalog.channelAt(0, 1)?.title, 'CCTV-2 财经');
      expect(catalog.channelAt(1, 0)?.title, '湖南卫视');
      expect(catalog.channelAt(9, 0), isNull);
      expect(catalog.channelAt(0, 9), isNull);
    });

    test('parses ids, logos, scheme filtering and backup lines', () {
      final first = catalog.channels.first;
      expect(first.id, 'cctv1');
      expect(first.logo, 'https://img.example.com/cctv1.png');
      expect(first.urls.map((uri) => uri.toString()).toList(), [
        'http://live.example.com/cctv1.m3u8',
      ]);
      // tvg-name wins over tvg-id, exactly like the source app.
      expect(catalog.channels[1].id, 'CCTV-2');
      expect(catalog.channels[1].urls.map((uri) => uri.toString()).toList(), [
        'http://live.example.com/cctv2.m3u8',
        'http://live.example.com/cctv2-backup.m3u8',
      ]);
      expect(catalog.channels[2].urls.single.toString(), 'rtsp://live.example.com/hunan');
    });

    test('keeps commas after the first separator in channel names', () {
      final result = parser.parse(
        '#EXTM3U\n#EXTINF:-1,频道,带逗号\nhttp://live.example.com/a.m3u8\n',
      );
      expect(result.channels.single.title, '频道,带逗号');
    });

    test('parses the last playlist line without a trailing newline', () {
      final result = parser.parse(
        '#EXTM3U\n#EXTINF:-1,最后一个\nhttp://live.example.com/last.m3u8',
      );
      expect(result.channels.single.title, '最后一个');
      expect(result.channels.single.urls.single.toString(), 'http://live.example.com/last.m3u8');
    });

    test('drops non-playable udp links but keeps the channel', () {
      final result = parser.parse(
        '#EXTM3U\n#EXTINF:-1,组播\nudp://239.1.1.1:5000\n',
      );
      expect(result.channelCount, 1);
      expect(result.channels.single.urls, isEmpty);
      expect(result.channels.single.hasPlayableUrl, isFalse);
    });

    test('reads #UA-Hint into the catalog', () {
      final result = parser.parse(_uaFixture);
      expect(result.uaHint, 'Mozilla/5.0');
      expect(result.channelCount, 1);
      expect(result.channels.single.title, '频道');
    });

    test('empty and header-only sources parse to an empty catalog', () {
      expect(parser.parse('').isEmpty, isTrue);
      expect(parser.parse('').type, EasyTvPlaylistType.txt);
      expect(parser.parse('#EXTM3U').isEmpty, isTrue);
      final noUrl = parser.parse('#EXTINF:-1,无地址\n');
      expect(noUrl.channelCount, 1);
      expect(noUrl.channels.single.urls, isEmpty);
    });
  });

  group('EasyTvCatalogParser txt', () {
    test('groups channels by #genre# section and splits #-joined URLs', () {
      final catalog = parser.parse(_txtFixture);
      expect(catalog.type, EasyTvPlaylistType.txt);
      expect(catalog.groupNames, ['央视', '卫视']);
      expect(catalog.channelCount, 3);
      expect(
        catalog.channels.map((channel) => channel.title).toList(),
        ['CCTV-1 综合', 'CCTV-2 财经', '湖南卫视'],
      );
      expect(catalog.channels[2].urls.map((uri) => uri.toString()).toList(), [
        'http://live.example.com/hunan-a.m3u8',
        'http://live.example.com/hunan-b.m3u8',
      ]);
      expect(catalog.channels[2].serialNum, 3);
      expect(catalog.channels[2].groupIndex, 1);
    });

    test('names an unlabelled section after its line number', () {
      final catalog = parser.parse('first,http://live.example.com/a.m3u8\n');
      expect(catalog.groupNames, ['默认']);
      expect(catalog.channelCount, 1);
    });
  });

  group('EasyTvCatalogRepository', () {
    test('fetches, parses and caches a playlist', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = EasyTvCatalogRepository(
        client: MockClient((request) async {
          expect(request.url.toString(), 'http://example.com/list.m3u');
          return http.Response(_m3uFixture, 200, headers: {'content-type': 'text/plain; charset=utf-8'});
        }),
      );
      addTearDown(repository.dispose);

      final catalog = await repository.load('http://example.com/list.m3u');
      expect(catalog.channelCount, 4);
      expect(catalog.channels[2].title, '湖南卫视');
      final cached = await const EasyTvCatalogCache().load();
      expect(cached, _m3uFixture);
    });

    test('sends the subscription ua query parameter as User-Agent', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      late http.Request captured;
      final repository = EasyTvCatalogRepository(
        client: MockClient((request) async {
          captured = request;
          return http.Response(_uaFixture, 200, headers: {'content-type': 'text/plain; charset=utf-8'});
        }),
      );
      addTearDown(repository.dispose);

      final catalog = await repository.load(
        'http://example.com/list.m3u?ua=MyAgent%2F1.0',
      );
      expect(
        captured.headers['user-agent'] ?? captured.headers['User-Agent'],
        'MyAgent/1.0',
      );
      expect(catalog.uaHint, 'MyAgent/1.0');
      expect(catalog.channelCount, 1);
    });

    test('falls back to the cached playlist on HTTP failure', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        EasyTvCatalogCache.storageKey: _m3uFixture,
      });
      final repository = EasyTvCatalogRepository(
        client: MockClient((request) async => http.Response('', 500)),
      );
      addTearDown(repository.dispose);

      final catalog = await repository.load('http://example.com/list.m3u');
      expect(catalog.channelCount, 4);
      expect(catalog.channels.first.title, 'CCTV-1 综合');
    });

    test('reports the HTTP status when no cache is available', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = EasyTvCatalogRepository(
        client: MockClient((request) async => http.Response('', 503)),
      );
      addTearDown(repository.dispose);

      await expectLater(
        repository.load('http://example.com/list.m3u'),
        throwsA(
          isA<Exception>().having(
            (error) => '$error',
            'message',
            contains('订阅请求失败：HTTP 503'),
          ),
        ),
      );
    });

    test('rejects non-http links and empty playlists', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = EasyTvCatalogRepository(
        client: MockClient((request) async => http.Response('', 200)),
      );
      addTearDown(repository.dispose);

      await expectLater(
        repository.load('ftp://example.com/list.m3u'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '仅支持 HTTP/HTTPS 订阅地址',
          ),
        ),
      );
      await expectLater(
        repository.load('http://example.com/empty.m3u'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '订阅中没有可播放频道',
          ),
        ),
      );
    });

    test('resolves the default pseudo-link through the public playlist mirror', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = EasyTvCatalogRepository(
        env: const EasyTvEnv(proxyIndex: 0),
        client: MockClient((request) async {
          expect(request.url.toString(), EasyTvEnv.defaultPlaylistUrl);
          return http.Response(_txtFixture, 200, headers: {'content-type': 'text/plain; charset=utf-8'});
        }),
      );
      addTearDown(repository.dispose);

      final catalog = await repository.load(EasyTvSource.defaultLink);
      expect(catalog.groupNames, ['央视', '卫视']);
    });
  });

  group('EasyTvEnv', () {
    test('builds mirror URLs and resolves the default link', () {
      const env = EasyTvEnv(proxyIndex: 1);
      expect(env.playlistUrl, '${EasyTvEnv.proxyPrefixes[1]}${EasyTvEnv.defaultPlaylistUrl}');
      expect(env.resolve('default'), env.playlistUrl);
      expect(env.resolve('http://example.com/x.m3u'), 'http://example.com/x.m3u');
      const direct = EasyTvEnv(proxyIndex: 0);
      expect(direct.playlistUrl, EasyTvEnv.defaultPlaylistUrl);
      const outOfRange = EasyTvEnv(proxyIndex: 9);
      expect(outOfRange.playlistUrl, EasyTvEnv.defaultPlaylistUrl);
    });
  });

  group('EasyTvPlaybackController', () {
    late EasyTvCatalog catalog;

    setUp(() => catalog = parser.parse(_m3uFixture));

    test('restores a serial, selects the first line and its URL', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 2);
      expect(controller.channel?.title, 'CCTV-2 财经');
      expect(controller.lineIndex, 0);
      expect(controller.lineLabel, '线路 1');
      expect(controller.currentUrl.toString(), 'http://live.example.com/cctv2.m3u8');
      expect(controller.lineCount, 2);
      expect(controller.requestHeaders, isEmpty);
    });

    test('fails over to the next line and clamps at the last line', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 2);
      expect(controller.handleLineFailure(), EasyTvLineFailure.switched);
      expect(controller.currentUrl.toString(), 'http://live.example.com/cctv2-backup.m3u8');
      expect(controller.lineLabel, '线路 2');
      expect(controller.handleLineFailure(), EasyTvLineFailure.exhausted);
      expect(controller.lineIndex, 1);
      expect(controller.currentUrl.toString(), 'http://live.example.com/cctv2-backup.m3u8');
    });

    test('manual line switching wraps around', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 2);
      expect(controller.selectLine(1), isTrue);
      expect(controller.currentUrl.toString(), 'http://live.example.com/cctv2-backup.m3u8');
      expect(controller.selectLine(1), isFalse);
      expect(controller.selectLine(7), isFalse);
      expect(controller.lineIndex, 1);
      expect(controller.switchLine(), isTrue);
      expect(controller.lineIndex, 0);
      expect(controller.switchLine(), isFalse);
      expect(controller.lineIndex, 1);
    });

    test('walks global serials without wrapping', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 2);
      expect(controller.previousChannel()?.title, 'CCTV-1 综合');
      expect(controller.serialNum, 1);
      expect(controller.previousChannel(), isNull);
      expect(controller.serialNum, 1);
      expect(controller.nextChannel()?.title, 'CCTV-2 财经');
      controller.openSerial(4);
      expect(controller.nextChannel(), isNull);
      expect(controller.serialNum, 4);
    });

    test('opens by drawer coordinates and drops stale indices', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 1);
      expect(controller.openAt(0, 1), isTrue);
      expect(controller.channel?.title, 'CCTV-2 财经');
      expect(controller.openAt(3, 0), isFalse);
      expect(controller.channel?.title, 'CCTV-2 财经');
      expect(controller.openSerial(99), isFalse);
      expect(controller.channel, isNull);
      expect(controller.serialNum, 0);
      expect(controller.currentUrl, isNull);
      expect(controller.handleLineFailure(), EasyTvLineFailure.exhausted);
      expect(controller.switchLine(), isFalse);
    });

    test('keeps the serial when the catalog is refreshed', () {
      final controller = EasyTvPlaybackController(catalog: catalog, serialNum: 3);
      expect(controller.channel?.title, '湖南卫视');
      final refreshed = parser.parse(_txtFixture);
      expect(controller.setCatalog(refreshed), isTrue);
      expect(controller.channel?.title, '湖南卫视');
      expect(controller.serialNum, 3);
      expect(controller.selectLine(1), isTrue);
      expect(controller.currentUrl.toString(), 'http://live.example.com/hunan-b.m3u8');
    });

    test('carries the playlist User-Agent in request headers', () {
      final controller = EasyTvPlaybackController(
        catalog: parser.parse(_uaFixture),
      );
      expect(controller.requestHeaders, {'User-Agent': 'Mozilla/5.0'});
      expect(controller.currentUrl.toString(), 'http://live.example.com/ua.m3u8');
    });
  });

  group('EasyTvSourceStore', () {
    test('selects one source and adds without duplicating links', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = EasyTvSourceStore();
      final added = EasyTvSourceStore.add(
        <EasyTvSource>[
          const EasyTvSource(link: 'default', selected: true),
        ],
        const EasyTvSource(link: 'http://example.com/a.m3u', time: '2026-10-18 06:00:00'),
      );
      expect(added.length, 2);
      expect(added.last.link, 'http://example.com/a.m3u');
      expect(added.last.selected, isTrue);
      expect(added.first.selected, isFalse);

      final duplicated = EasyTvSourceStore.add(
        added,
        const EasyTvSource(link: 'http://example.com/a.m3u'),
      );
      expect(duplicated.length, 2);

      await store.save(added);
      final loaded = await store.load();
      expect(loaded.map((source) => source.link).toList(), [
        'default',
        'http://example.com/a.m3u',
      ]);
      expect(loaded.last.selected, isTrue);
      expect(EasyTvSourceStore.selectedOrDefault(loaded).link, 'http://example.com/a.m3u');
    });

    test('removing the selected source promotes the first survivor', () {
      const sources = <EasyTvSource>[
        EasyTvSource(link: 'default'),
        EasyTvSource(link: 'http://example.com/a.m3u', selected: true),
      ];
      final remaining = EasyTvSourceStore.remove(sources, 'http://example.com/a.m3u');
      expect(remaining.length, 1);
      expect(remaining.single.link, 'default');
      expect(remaining.single.selected, isTrue);

      final emptied = EasyTvSourceStore.remove(sources, 'default');
      expect(emptied.length, 1);
      expect(emptied.single.link, 'http://example.com/a.m3u');

      final allGone = EasyTvSourceStore.remove(
        <EasyTvSource>[const EasyTvSource(link: 'default', selected: true)],
        'default',
      );
      expect(allGone.single.link, EasyTvSource.defaultLink);
      expect(allGone.single.selected, isTrue);
    });

    test('empty storage yields a selected default source', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = EasyTvSourceStore();
      expect(await store.load(), isEmpty);
      final selected = EasyTvSourceStore.selectedOrDefault(const <EasyTvSource>[]);
      expect(selected.isDefault, isTrue);
      expect(selected.selected, isTrue);
      expect(selected.displayLink, '默认公共源');
    });
  });

  group('EasyTvSettingsStore', () {
    test('persists the last channel and clamps settings ranges', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const store = EasyTvSettingsStore();
      expect(await store.loadPrePlaySerial(), isNull);
      expect(await store.loadTimeoutSeconds(), EasyTvSettingsStore.defaultTimeoutSeconds);

      await store.savePrePlaySerial(7);
      expect(await store.loadPrePlaySerial(), 7);
      await store.savePrePlaySerial(0);
      expect(await store.loadPrePlaySerial(), 7);

      await store.saveTimeoutSeconds(1);
      expect(await store.loadTimeoutSeconds(), 5);
      await store.saveTimeoutSeconds(999);
      expect(await store.loadTimeoutSeconds(), 60);

      await store.saveProxyIndex(-3);
      expect(await store.loadProxyIndex(), 0);
      await store.saveProxyIndex(9);
      expect(await store.loadProxyIndex(), 2);
    });
  });

  group('EasyTvPage', () {
    testWidgets('renders the restored channel, counts and drawer order', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        EasyTvSettingsStore.prePlaySerialKey: 3,
      });
      final catalog = parser.parse(_m3uFixture);
      await tester.pumpWidget(
        MaterialApp(home: EasyTvPage(repository: _FakeRepository(catalog))),
      );
      await tester.pumpAndSettle();

      expect(find.text('湖南卫视'), findsWidgets);
      expect(find.text('分组：卫视'), findsOneWidget);
      expect(find.text('共 4 个频道 · 3 个分组'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('央视（2）'), findsOneWidget);
      expect(find.text('卫视（1）'), findsOneWidget);
      expect(find.text('3 湖南卫视'), findsOneWidget);
      expect(find.text('默认公共源'), findsOneWidget);

      await tester.tap(find.text('央视（2）'));
      await tester.pumpAndSettle();
      expect(find.text('1 CCTV-1 综合'), findsOneWidget);
      expect(find.text('2 CCTV-2 财经'), findsOneWidget);
    });

    testWidgets('shows a retry state when the subscription fails', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        MaterialApp(home: EasyTvPage(repository: _FailingRepository())),
      );
      await tester.pumpAndSettle();

      expect(find.text('加载失败：订阅请求失败：HTTP 500'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '重试'), findsOneWidget);
    });
  });

  group('EasyTvSourcePage', () {
    testWidgets('adds a network source and rejects a non-http link', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const MaterialApp(home: EasyTvSourcePage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);

      await tester.tap(find.text('添加订阅源'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'http://example.com/list.m3u',
      );
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.text('http://example.com/list.m3u'), findsOneWidget);
      expect(find.textContaining('使用中'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString(EasyTvSourceStore.storageKey)!)
          as List<dynamic>;
      expect(stored.length, 1);
      expect((stored.single as Map<String, dynamic>)['link'], 'http://example.com/list.m3u');
      expect((stored.single as Map<String, dynamic>)['selected'], isTrue);
      expect(
        (stored.single as Map<String, dynamic>)['time'],
        isA<String>().having((value) => value.length, 'timestamp length', 19),
      );

      await tester.tap(find.text('添加订阅源'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ftp://example.com/list.m3u');
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.text('订阅地址必须以 http/https 开头'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('restores the default source', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        const MaterialApp(home: EasyTvSourcePage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('恢复默认源'));
      await tester.pumpAndSettle();

      expect(find.text('默认公共源'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString(EasyTvSourceStore.storageKey)!)
          as List<dynamic>;
      expect(stored.length, 1);
      expect((stored.single as Map<String, dynamic>)['link'], EasyTvSource.defaultLink);
    });
  });
}

class _FailingRepository extends EasyTvCatalogRepository {
  @override
  Future<EasyTvCatalog> load(String link) async {
    throw Exception('订阅请求失败：HTTP 500');
  }
}
