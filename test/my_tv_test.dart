import 'package:dashboard/features/live/my_tv/my_tv_cache_entry.dart';
import 'package:dashboard/features/live/my_tv/my_tv_channel.dart';
import 'package:dashboard/features/live/my_tv/my_tv_controller.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_guide.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_parser.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_repository.dart';
import 'package:dashboard/features/live/my_tv/my_tv_group.dart';
import 'package:dashboard/features/live/my_tv/my_tv_page.dart';
import 'package:dashboard/features/live/my_tv/my_tv_playlist_parser.dart';
import 'package:dashboard/features/live/my_tv/my_tv_timer.dart';
import 'package:dashboard/features/live/my_tv/my_tv_ttl_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _tvbox = '''央视,#genre#
CCTV-1,http://iptv.example.com/cctv1.m3u8
CCTV-2,http://iptv.example.com/cctv2.m3u8
卫视,#genre#
湖南卫视,http://iptv.example.com/hunan.m3u8#http://iptv.example.com/hunan2.m3u8
浙江卫视，http://iptv.example.com/zjws.m3u8
''';

const _m3u = '''#EXTM3U
#EXTINF:-1 tvg-id="cctv1" tvg-name="CCTV-1" tvg-logo="http://logo.example.com/1.png" group-title="央视",CCTV-1 综合
http://iptv.example.com/cctv1.m3u8
#EXTINF:-1 tvg-id="hunan" tvg-name="湖南卫视" group-title="卫视",湖南卫视
http://iptv.example.com/hunan.m3u8
#EXTINF:-1 group-title="地方",浙江民生
http://iptv.example.com/zj.m3u8
''';

const _xmltv = '''<?xml version="1.0" encoding="UTF-8"?>
<tv generator-info-name="test">
  <channel id="cctv1"><display-name lang="zh">CCTV-1</display-name></channel>
  <channel id="hunan"><display-name>湖南卫视</display-name></channel>
  <programme start="20260116210000 +0800" stop="20260116223000 +0800" channel="cctv1"><title>焦点访谈 &amp; 天气预报</title></programme>
  <programme start="20260116200000 +0800" stop="20260116210000 +0800" channel="cctv1"><title lang="zh">新闻联播</title></programme>
  <programme start="20260116190000 +0800" stop="20260116200000 +0800" channel="hunan"><title>综艺</title></programme>
</tv>''';

void main() {
  group('MyTvPlaylistParser', () {
    test('TVbox #genre# splits groups, joins backup URLs and numbers', () {
      final groups = const MyTvPlaylistParser().parse(_tvbox);
      expect(groups.map((g) => g.name), ['央视', '卫视']);
      expect(groups[0].channels.map((c) => c.name), ['CCTV-1', 'CCTV-2']);
      expect(groups[1].channels.map((c) => c.name), ['湖南卫视', '浙江卫视']);
      // Sequential numbering runs across groups after parsing.
      expect(groups[0].channels.map((c) => c.number), [1, 2]);
      expect(groups[1].channels.map((c) => c.number), [3, 4]);
      // '#' separated TVbox entries become multiple playable URLs.
      expect(groups[1].channels.first.urls, hasLength(2));
      expect(
        groups[1].channels.first.urls.first.toString(),
        'http://iptv.example.com/hunan.m3u8',
      );
      // Full-width comma separator is normalised.
      expect(
        groups[1].channels.last.urls.single.toString(),
        'http://iptv.example.com/zjws.m3u8',
      );
      // TVbox channels key EPG off their own name.
      expect(groups[0].channels.first.tvgName, 'CCTV-1');
    });

    test('M3U keeps tvg-name, simplifies to CCTV/卫视 and renumbers', () {
      final groups = const MyTvPlaylistParser().parse(_m3u);
      expect(groups.map((g) => g.name), ['央视', '卫视', '地方']);
      expect(groups.expand((g) => g.channels).map((c) => c.number), [1, 2, 3]);
      // tvg-name survives even though tvg-id is present.
      expect(groups[0].channels.single.tvgName, 'CCTV-1');
      expect(
        groups[0].channels.single.logo.toString(),
        'http://logo.example.com/1.png',
      );
      // A channel without tvg-name falls back to its display name.
      expect(groups[2].channels.single.tvgName, '浙江民生');

      final simplified = const MyTvPlaylistParser().parse(_m3u, simplify: true);
      expect(simplified.expand((g) => g.channels).map((c) => c.name), [
        'CCTV-1 综合',
        '湖南卫视',
      ]);
      expect(simplified.expand((g) => g.channels).map((c) => c.number), [1, 2]);
      expect(simplified.map((g) => g.name), ['央视', '卫视']);
    });

    test('empty input yields no groups', () {
      expect(const MyTvPlaylistParser().parse('   '), isEmpty);
    });
  });

  group('MyTvEpgParser', () {
    test('matches display-name to programmes and sorts by start', () {
      final programmes = const MyTvEpgParser().parse(_xmltv);
      expect(programmes.keys.toSet(), {'CCTV-1', '湖南卫视'});
      expect(programmes['CCTV-1']!.map((p) => p.title), [
        '新闻联播',
        '焦点访谈 & 天气预报',
      ]);
      // Numeric/entity decoding plus the 14-digit start/stop conversion.
      expect(
        programmes['CCTV-1']!.first.start,
        DateTime(2026, 1, 16, 20).millisecondsSinceEpoch,
      );
      expect(
        programmes['CCTV-1']!.first.stop,
        DateTime(2026, 1, 16, 21).millisecondsSinceEpoch,
      );
    });

    test('current/next lookup and channel filtering', () {
      final guide = MyTvEpgGuide(const MyTvEpgParser().parse(_xmltv));
      final now = DateTime(2026, 1, 16, 20, 30).millisecondsSinceEpoch;
      expect(guide.currentAt('CCTV-1', now)?.title, '新闻联播');
      expect(guide.nextAt('CCTV-1', now)?.title, '焦点访谈 & 天气预报');
      // After the last programme there is nothing next.
      final late = DateTime(2026, 1, 16, 23, 0).millisecondsSinceEpoch;
      expect(guide.currentAt('CCTV-1', late), isNull);
      expect(guide.nextAt('CCTV-1', late), isNull);

      final filtered = const MyTvEpgParser().parse(_xmltv, channels: {'湖南卫视'});
      expect(filtered.containsKey('CCTV-1'), isFalse);
      expect(filtered['湖南卫视']!.single.title, '综艺');
    });

    test('controller exposes current/next for the selected channel', () {
      final guide = MyTvEpgGuide(const MyTvEpgParser().parse(_xmltv));
      final controller = MyTvController(
        groups: [
          MyTvGroup(
            index: 0,
            name: '央视',
            channels: const [
              MyTvChannel(
                number: 1,
                name: 'CCTV-1 综合',
                group: '央视',
                tvgName: 'CCTV-1',
                urls: [],
              ),
            ],
          ),
        ],
        guide: guide,
        now: () => DateTime(2026, 1, 16, 20, 30),
      );
      final programmes = controller.programmesFor(controller.current!);
      expect(programmes.current, '新闻联播');
      expect(programmes.next, '焦点访谈 & 天气预报');
    });
  });

  group('MyTvTtlCache', () {
    test('24h boundary is exact under an injected clock', () async {
      final memory = _MemoryCache();
      var now = DateTime(2026, 1, 1, 12);
      final cache = MyTvTtlCache(
        read: memory.read,
        write: memory.write,
        now: () => now,
        ttl: const Duration(hours: 24),
      );

      expect(await cache.get(), isNull);
      await cache.put('SOURCE');
      expect(await cache.get(), 'SOURCE');

      now = DateTime(2026, 1, 2, 11, 59, 59);
      expect(await cache.get(), 'SOURCE');

      // Exactly 24h old is already stale, mirroring `now - cache < keep`.
      now = DateTime(2026, 1, 2, 12);
      expect(await cache.get(), isNull);

      await cache.put('');
      expect(await cache.get(), isNull);
      expect(memory.entry!.content, '');
    });

    test(
      'EPG repository reuses the same day and skips pre-threshold refresh',
      () async {
        final memory = _MemoryCache();
        var now = DateTime(2026, 1, 16, 5);
        var fetches = 0;
        final repository = MyTvEpgRepository(
          read: memory.read,
          write: memory.write,
          now: () => now,
          refreshHour: 6,
          fetchXml: () async {
            fetches++;
            return _xmltv;
          },
        );

        // Before the threshold on a fresh day: no fetch, no guide.
        final early = await repository.load(channels: {'CCTV-1'});
        expect(early.isEmpty, isTrue);
        expect(fetches, 0);

        now = DateTime(2026, 1, 16, 9);
        final loaded = await repository.load(channels: {'CCTV-1'});
        expect(fetches, 1);
        expect(
          loaded
              .currentAt(
                'CCTV-1',
                DateTime(2026, 1, 16, 20, 30).millisecondsSinceEpoch,
              )
              ?.title,
          '新闻联播',
        );

        // Same calendar day: served from cache, still one fetch.
        now = DateTime(2026, 1, 16, 22);
        await repository.load(channels: {'CCTV-1'});
        expect(fetches, 1);

        // Next day before the threshold: empty again, no fetch.
        now = DateTime(2026, 1, 17, 5);
        final nextDay = await repository.load(channels: {'CCTV-1'});
        expect(nextDay.isEmpty, isTrue);
        expect(fetches, 1);
      },
    );
  });

  group('MyTvController navigation', () {
    test('prev/next channel and group wrap around', () {
      final groups = _twoGroups();
      final controller = MyTvController(groups: groups);
      expect(controller.current!.number, 1);

      // Flat wrap: backwards from the first lands on the last channel.
      expect(controller.previousChannel()!.number, 5);
      // And forwards from the last returns to the first.
      expect(controller.nextChannel()!.number, 1);

      // Group wrap: A -> B is B's first channel, B -> A is A's first.
      expect(controller.nextGroupChannel()!.number, 4);
      expect(controller.previousGroupChannel()!.number, 1);

      controller.select(groups[0].channels[1]);
      expect(controller.current!.number, 2);
      expect(controller.previousGroupChannel()!.number, 4);
      expect(controller.nextGroupChannel()!.number, 1);
    });

    test('group navigation skips an empty group', () {
      final controller = MyTvController(
        groups: [
          _twoGroups()[0],
          const MyTvGroup(index: 1, name: '空组', channels: []),
          _twoGroups()[1],
        ],
      );
      expect(controller.nextGroupChannel()!.number, 4);
    });
  });

  group('MyTvController numeric entry', () {
    test('digits auto-confirm after 4s and select the channel', () {
      late _FakeTimer timer;
      Duration? delay;
      MyTvTimer factory(Duration duration, void Function() callback) {
        delay = duration;
        timer = _FakeTimer(callback);
        return timer;
      }

      final controller = MyTvController(
        groups: [_numberedGroup(15)],
        timerFactory: factory,
      );
      expect(controller.current!.number, 1);

      controller.inputChannelNo('1');
      expect(controller.channelNo, '1');
      expect(delay, const Duration(seconds: 3));
      final first = timer;

      // A second digit restarts a shorter timer (4s from the first digit).
      controller.inputChannelNo('2');
      expect(controller.channelNo, '12');
      expect(delay, const Duration(seconds: 2));
      expect(first.cancelled, isTrue);

      timer.fire();
      expect(controller.channelNo, '');
      expect(controller.current!.number, 12);

      // An unknown number leaves the current channel untouched.
      controller.inputChannelNo('9');
      controller.inputChannelNo('9');
      timer.fire();
      expect(controller.current!.number, 12);
    });
  });

  testWidgets('MyTvPage renders an injected controller without network', (
    tester,
  ) async {
    final controller = MyTvController(groups: [_twoGroups()[0]]);
    await tester.pumpWidget(
      MaterialApp(home: MyTvPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的电视 · my_tv'), findsOneWidget);
    expect(find.text('A1'), findsWidgets);
    expect(controller.current!.number, 1);

    await tester.tap(find.text('下一个'));
    await tester.pumpAndSettle();
    expect(controller.current!.number, 2);
    expect(find.text('A2'), findsWidgets);

    await tester.tap(find.text('上一组'));
    await tester.pumpAndSettle();
    // Only group A is present, so it wraps back onto itself.
    expect(controller.current!.number, 1);
  });
}

List<MyTvGroup> _twoGroups() => [
  MyTvGroup(
    index: 0,
    name: 'A组',
    channels: [
      _channel(1, 'A1', 'A组', 'A-1'),
      _channel(2, 'A2', 'A组', 'A-2'),
      _channel(3, 'A3', 'A组', 'A-3'),
    ],
  ),
  MyTvGroup(
    index: 1,
    name: 'B组',
    channels: [_channel(4, 'B1', 'B组', 'B-1'), _channel(5, 'B2', 'B组', 'B-2')],
  ),
];

MyTvGroup _numberedGroup(int count) => MyTvGroup(
  index: 0,
  name: '全部',
  channels: [
    for (var number = 1; number <= count; number++)
      _channel(number, 'CH$number', '全部', 'CH$number'),
  ],
);

MyTvChannel _channel(int number, String name, String group, String tvgName) =>
    MyTvChannel(
      number: number,
      name: name,
      group: group,
      tvgName: tvgName,
      urls: [Uri.parse('http://iptv.example.com/$number.m3u8')],
    );

class _MemoryCache {
  MyTvCacheEntry? entry;

  Future<MyTvCacheEntry?> read() async => entry;

  Future<void> write(MyTvCacheEntry value) async {
    entry = value;
  }
}

class _FakeTimer implements MyTvTimer {
  _FakeTimer(this.callback);

  final void Function() callback;
  bool cancelled = false;

  @override
  void cancel() => cancelled = true;

  void fire() {
    if (!cancelled) callback();
  }
}
