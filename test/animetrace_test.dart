// Tests for the ported AnimeTrace (漫迹) module.
//
// Everything here runs without a network:
//  * the scrapers are pure `String -> domain object` parsers, so real site
//    markup is committed as fixture HTML;
//  * the dedup / lapse-cover / import rules are pure functions;
//  * the DAO round-trips run against a real SQLite engine. The host has no
//    `sqflite_common_ffi` dependency (and this port may not add one), and the
//    sqflite plugin cannot answer inside `flutter test`, so a small `dart:ffi`
//    binding to the platform's own sqlite3 stands in for the plugin. The SQL
//    executed is exactly the SQL the DAOs run in production.
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_dedup.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_health_probe.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_import.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_lapse_cover_fix.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_play_status.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_agemys_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_bangumi_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_omofun_scraper.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_scrape_util.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_source_catalog.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_stream_extractor.dart';
import 'package:dashboard/features/anime/animetrace/scrapers/animetrace_yhdm_scraper.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_episode_note_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_history_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _scraperTests();
  _pureLogicTests();
  _databaseTests();
  _healthProbeTests();
}

// --------------------------------------------------------------- fixtures ---

/// Search result page shape of www.agedm.org (`div.cata_video_item`).
const String _agemysSearchHtml = '''
<!DOCTYPE html>
<html><body>
  <div class="cata_video_item">
    <a href="/detail/1234">
      <img data-original="//cdn.agedm.org/cover/frieren.jpg" alt="葬送的芙莉莲">
    </a>
    <div class="video_play_status">更新至第28集</div>
  </div>
  <div class="cata_video_item">
    <a href="/detail/5678">
      <img data-original="//cdn.agedm.org/cover/bocchi.jpg" alt="孤独摇滚！">
    </a>
    <div class="video_play_status">[全集]</div>
  </div>
</body></html>
''';

/// Detail page shape of www.agedm.org.
const String _agemysDetailHtml = '''
<!DOCTYPE html>
<html><body>
  <div class="detail_imform_value">日本</div>
  <div class="detail_imform_value">TV</div>
  <div class="detail_imform_value">葬送のフリーレン</div>
  <div class="detail_imform_value">葬送的芙莉莲</div>
  <div class="detail_imform_value">山田鐘人</div>
  <div class="detail_imform_value">MADHOUSE</div>
  <div class="detail_imform_value">2023-09-29</div>
  <div class="detail_imform_value">已完结</div>
  <div class="video_detail_desc">魔王被打倒之后，勇者一行各奔东西。<br>芙莉莲踏上了新的旅途。</div>
  <div class="video_detail_cover"><img data-original="//cdn.agedm.org/cover/frieren.jpg"></div>
  <ul class="video_detail_episode">
    <li><a href="/play/1234/0">PV</a></li>
  </ul>
  <ul class="video_detail_episode">
    <li><a href="/play/1234/1">第1集</a></li>
    <li><a href="/play/1234/2">第2集</a></li>
    <li><a href="/play/1234/3">第3集</a></li>
  </ul>
</body></html>
''';

/// Search result page shape of www.iyhdmm.com (`div.lpic > ul > li`).
const String _yhdmSearchHtml = '''
<!DOCTYPE html>
<html><body>
  <div class="lpic">
    <ul>
      <li>
        <a href="/show/1234.html"><img src="//pic.iyhdmm.com/frieren.jpg" alt="葬送的芙莉莲"></a>
        <p>魔王被打倒之后的故事。</p>
        <font>[TV 01-28]</font>
      </li>
      <li>
        <a href="/show/5678.html"><img src="//pic.iyhdmm.com/bocchi.jpg" alt="孤独摇滚！"></a>
        <p>社恐少女的乐队日常。</p>
        <font>更新至第12话</font>
      </li>
    </ul>
  </div>
</body></html>
''';

/// Detail page shape of www.iyhdmm.com (`div.sinfo`).
const String _yhdmDetailHtml = '''
<!DOCTYPE html>
<html><body>
  <div class="sinfo">
    <p><a href="/x" target="_blank">葬送のフリーレン</a><br>原名：葬送のフリーレン</p>
    <span>首播：<a href="/search?year=2023" target="_blank">2023-09-29</a></span>
    <span>地区：<a href="/area/jp">日本</a></span>
    <span>年代：<a href="/year/2023">2023</a></span>
    <span>语言：<a href="/lang/jp">日语</a></span>
    <span>类型：<a href="/type/tv">TV</a> <a href="/type/animation">动画</a> <a href="/status">已完结</a></span>
  </div>
  <div class="thumb"><img src="//pic.iyhdmm.com/frieren.jpg"></div>
  <div class="info">魔王被打倒之后，勇者一行各奔东西。<br>芙莉莲踏上了新的旅途。</div>
  <p>更新至第28集</p>
</body></html>
''';

/// Search result page shape of omofun.tv: four parallel node lists.
const String _omofunSearchHtml = '''
<!DOCTYPE html>
<html><body>
  <div class="module-list">
    <div class="module-card-item">
      <img class="lazy lazyload" data-original="//img.omofun.tv/frieren.jpg" alt="葬送的芙莉莲">
      <div class="module-card-item-info">
        <a href="/vod/detail/id/1.html"></a>
        <div class="module-info-item-content">2023<span class="slash">/</span>日本</div>
      </div>
      <div class="module-item-note">更新至28集</div>
      <div class="module-card-item-class">日韩动漫</div>
    </div>
    <div class="module-card-item">
      <img class="lazy lazyload" data-original="//img.omofun.tv/bocchi.jpg" alt="孤独摇滚！">
      <div class="module-card-item-info">
        <a href="/vod/detail/id/2.html"></a>
        <div class="module-info-item-content">2022<span class="slash">/</span>日本</div>
      </div>
      <div class="module-item-note">已完结</div>
      <div class="module-card-item-class">日韩动漫</div>
    </div>
  </div>
</body></html>
''';

/// Search result page shape of bangumi.tv (`#browserItemList`).
const String _bangumiSearchHtml = '''
<!DOCTYPE html>
<html><body>
  <div id="browserItemList">
    <ul>
      <li>
        <a href="/subject/400602" class="cover"><img src="//lain.bgm.tv/pic/cover/l/frieren.jpg"></a>
        <div class="inner">
          <a href="/subject/400602">葬送的芙莉莲</a>
          <small>葬送のフリーレン</small>
          <p class="info tip">28话 / 2023年9月29日 / MADHOUSE</p>
        </div>
      </li>
      <li>
        <a href="/subject/111111" class="cover"><img src="http://lain.bgm.tv/pic/cover/l/mahouka.jpg"></a>
        <div class="inner">
          <a href="/subject/111111">魔法科高校的劣等生 续篇</a>
          <small>魔法科高校の劣等生 続編</small>
          <p class="info tip">2024年4月5日</p>
        </div>
      </li>
    </ul>
  </div>
</body></html>
''';

// ---------------------------------------------------------------- scrapers ---

void _scraperTests() {
  group('AGE动漫 scraper (agedm.org)', () {
    const scraper = AnimeTraceAgemysScraper();

    test('parses the search result list', () {
      final animes = scraper.parseSearchResults(
        _agemysSearchHtml,
        baseUrl: scraper.defaultBaseUrl,
      );

      expect(animes, hasLength(2));
      expect(animes[0].animeName, '葬送的芙莉莲');
      expect(animes[0].animeCoverUrl, 'https://cdn.agedm.org/cover/frieren.jpg');
      expect(animes[0].animeUrl, 'https://www.agedm.org/detail/1234');
      expect(animes[0].animeEpisodeCnt, 28);
      expect(animes[1].animeName, '孤独摇滚！');
      expect(animes[1].animeEpisodeCnt, 1, reason: '[全集] means one episode');
    });

    test('applies the detail page fields and the largest episode list', () {
      final base = AnimeTraceAnime(
        animeName: '葬送的芙莉莲',
        animeUrl: 'https://www.agedm.org/detail/1234',
      );
      final anime = scraper.applyAnimeInfo(_agemysDetailHtml, base);

      expect(anime.area, '日本');
      expect(anime.category, 'TV');
      expect(anime.nameOri, '葬送のフリーレン');
      expect(anime.nameAnother, '葬送的芙莉莲');
      expect(anime.authorOri, '山田鐘人');
      expect(anime.productionCompany, 'MADHOUSE');
      expect(anime.premiereTime, '2023-09-29');
      expect(anime.playStatus, '已完结');
      expect(anime.animeEpisodeCnt, 3, reason: 'the PV list must be skipped');
      expect(
        anime.animeDesc,
        '魔王被打倒之后，勇者一行各奔东西。\n芙莉莲踏上了新的旅途。',
      );
      expect(anime.animeCoverUrl, 'https://cdn.agedm.org/cover/frieren.jpg');
      expect(anime.playStatusValue, AnimeTracePlayStatus.finished);
    });

    test('collects one URL per episode and skips the PV list', () {
      final urls = scraper.parseEpisodeUrls(
        _agemysDetailHtml,
        baseUrl: scraper.defaultBaseUrl,
      );

      expect(urls, <String>[
        'https://www.agedm.org/play/1234/1',
        'https://www.agedm.org/play/1234/2',
        'https://www.agedm.org/play/1234/3',
      ]);
    });

    test('builds the search URL from the configured base', () {
      expect(
        scraper.searchUrl('https://www.agedm.org', '芙莉莲'),
        'https://www.agedm.org/search?query=芙莉莲',
      );
    });
  });

  group('樱花动漫 scraper (iyhdmm.com)', () {
    const scraper = AnimeTraceYhdmScraper();

    test('parses the search result list', () {
      final animes = scraper.parseSearchResults(
        _yhdmSearchHtml,
        baseUrl: scraper.defaultBaseUrl,
      );

      expect(animes, hasLength(2));
      expect(animes[0].animeName, '葬送的芙莉莲');
      expect(animes[0].animeCoverUrl, 'https://pic.iyhdmm.com/frieren.jpg');
      expect(animes[0].animeUrl, 'https://www.iyhdmm.com/show/1234.html');
      expect(animes[0].animeEpisodeCnt, 28);
      expect(animes[1].animeName, '孤独摇滚！');
      expect(animes[1].animeEpisodeCnt, 12);
    });

    test('applies the detail page fields', () {
      final base = AnimeTraceAnime(animeName: '葬送的芙莉莲');
      final anime = scraper.applyAnimeInfo(_yhdmDetailHtml, base);

      expect(anime.nameAnother, '原名：葬送のフリーレン');
      expect(anime.premiereTime, '2023-09-29');
      expect(anime.area, '日本');
      expect(anime.category, 'TV');
      expect(anime.playStatus, '已完结');
      expect(anime.animeEpisodeCnt, 28);
      expect(
        anime.animeDesc,
        '魔王被打倒之后，勇者一行各奔东西。\n芙莉莲踏上了新的旅途。',
      );
      expect(anime.animeCoverUrl, 'https://pic.iyhdmm.com/frieren.jpg');
    });

    test('parseEpisodeCountOfYhdm handles every label shape', () {
      expect(parseEpisodeCountOfYhdm('[全集]'), 1);
      expect(parseEpisodeCountOfYhdm('更新至第12集'), 12);
      expect(parseEpisodeCountOfYhdm('第 28 话'), 28);
      expect(parseEpisodeCountOfYhdm('[TV 01-12+OVA+SP]'), 12);
      expect(parseEpisodeCountOfYhdm('连载中'), 0);
      expect(parseEpisodeCountOfYhdm(''), 0);
    });

    test('adjustEpisodeCountByStartNumber keeps the display count', () {
      expect(adjustEpisodeCountByStartNumber(28, 1), 28);
      expect(adjustEpisodeCountByStartNumber(28, 13), 16);
    });
  });

  group('OmoFun scraper (omofun.tv)', () {
    const scraper = AnimeTraceOmofunScraper();

    test('zips the four parallel search lists by index', () {
      final animes = scraper.parseSearchResults(
        _omofunSearchHtml,
        baseUrl: scraper.defaultBaseUrl,
      );

      expect(animes, hasLength(2));
      expect(animes[0].animeName, '葬送的芙莉莲');
      expect(animes[0].animeUrl, 'https://omofun.tv/vod/detail/id/1.html');
      expect(animes[0].premiereTime, '2023');
      expect(animes[0].area, '日本');
      expect(animes[0].playStatus, '更新至28集');
      expect(animes[0].category, '日韩动漫');
      expect(animes[1].animeName, '孤独摇滚！');
      expect(animes[1].premiereTime, '2022');
      expect(animes[1].playStatus, '已完结');
    });
  });

  group('Bangumi scraper (bangumi.tv)', () {
    const scraper = AnimeTraceBangumiScraper();

    test('parses #browserItemList, including the missing-cover case', () {
      final animes = scraper.parseSearchResults(
        _bangumiSearchHtml,
        baseUrl: scraper.defaultBaseUrl,
      );

      expect(animes, hasLength(2));
      expect(animes[0].animeName, '葬送的芙莉莲');
      expect(animes[0].nameAnother, '葬送のフリーレン');
      expect(animes[0].animeUrl, 'https://bangumi.tv/subject/400602');
      expect(animes[0].animeCoverUrl, 'https://lain.bgm.tv/pic/cover/l/frieren.jpg');
      expect(animes[0].animeEpisodeCnt, 28);
      expect(animes[0].premiereTime, '2023-09-29');
      expect(animes[0].tempInfo, '28话 / 2023年9月29日 / MADHOUSE');
      expect(animes[1].animeEpisodeCnt, 0);
      expect(animes[1].premiereTime, '2024-04-05');
    });

    test('normalizes the bangumi date shapes', () {
      expect(normalizeBangumiDate('2023年9月29日'), '2023-09-29');
      expect(normalizeBangumiDate('2023年10月'), '2023-10');
      expect(normalizeBangumiDate('2023年'), '2023');
      expect(normalizeBangumiDate('2023-09-29'), '2023-09-29');
      expect(normalizeBangumiDate('未定'), '');
    });

    test('builds collection URLs with the site page size', () {
      expect(AnimeTraceBangumiScraper.userCollectionPageSize, 24);
      expect(
        scraper.userCollectionUrl('https://bangumi.tv', 'nathaniel', 'wish'),
        'https://bangumi.tv/anime/list/nathaniel/wish?page=1',
      );
    });
  });

  group('shared scraper helpers', () {
    test('extracts a stream from a player page', () {
      expect(
        AnimeTraceStreamExtractor.extract(
          '<script>var player = {"url":"https:\\/\\/cdn.example.com\\/a\\/index.m3u8","id":1};</script>',
        ),
        'https://cdn.example.com/a/index.m3u8',
      );
      expect(
        AnimeTraceStreamExtractor.extract(
          '<video src="https://cdn.example.com/media/ep1.mp4"></video>',
        ),
        'https://cdn.example.com/media/ep1.mp4',
      );
      // Relative paths are deliberately rejected: the caller falls back to
      // "open in browser" instead of guessing a host.
      expect(
        AnimeTraceStreamExtractor.extract('<video src="/media/ep1.mp4"></video>'),
        isNull,
      );
      expect(AnimeTraceStreamExtractor.extract('<html>没有播放地址</html>'), isNull);
    });

    test('normalizes protocol-relative image URLs', () {
      expect(normalizeAnimeTraceImageUrl('//cdn.agedm.org/a.jpg'),
          'https://cdn.agedm.org/a.jpg');
      expect(normalizeAnimeTraceImageUrl('http://cdn.agedm.org/a.jpg'),
          'http://cdn.agedm.org/a.jpg');
      expect(normalizeAnimeTraceImageUrl(null), '');
      expect(normalizeAnimeTraceImageUrl('  '), '');
    });

    test('catalog maps anime URLs back to their source', () {
      const catalog = AnimeTraceSourceCatalog.defaults;

      final age = AnimeTraceSourceCatalog.sourceOfAnimeUrl(
        'https://www.agedm.org/detail/1234',
        sources: catalog,
      );
      expect(age?.climbId, 'age');
      final yhdm = AnimeTraceSourceCatalog.sourceOfAnimeUrl(
        'https://www.yhdmp.cc/show/1.html',
        sources: catalog,
      );
      expect(yhdm?.climbId, 'yhdm');
      final bangumi = AnimeTraceSourceCatalog.sourceOfAnimeUrl(
        'https://bgm.tv/subject/1',
        sources: catalog,
      );
      expect(bangumi?.climbId, 'bangumi');
      expect(bangumi?.supportPlayVideo, isFalse);
      expect(
        AnimeTraceSourceCatalog.sourceOfAnimeUrl(
          'https://example.com/anime/1',
          sources: catalog,
        ),
        isNull,
      );
    });

    test('catalog exposes one scraper per ported source', () {
      expect(
        AnimeTraceSourceCatalog.scrapers.map((s) => s.climbId).toSet(),
        <String>{'age', 'yhdm', 'omofun', 'bangumi'},
      );
      expect(AnimeTraceSourceCatalog.scraperOf('age')?.sourceName, 'AGE动漫');
      expect(AnimeTraceSourceCatalog.scraperOf('nope'), isNull);
    });
  });
}

// ------------------------------------------------------------- pure logic ---

void _pureLogicTests() {
  group('dedup rules', () {
    List<AnimeTraceAnime> duplicates() => <AnimeTraceAnime>[
          const AnimeTraceAnime(
            animeId: 11,
            animeName: '葬送的芙莉莲',
            animeUrl: 'https://www.agedm.org/detail/1234',
          ),
          const AnimeTraceAnime(
            animeId: 12,
            animeName: '葬送的芙莉莲',
            animeUrl: 'https://www.iyhdmm.com/show/1234.html',
            checkedEpisodeCnt: 7,
          ),
          const AnimeTraceAnime(
            animeId: 13,
            animeName: '葬送的芙莉莲',
            animeUrl: 'https://omofun.tv/vod/detail/id/1.html',
          ),
          const AnimeTraceAnime(
            animeId: 21,
            animeName: '孤独摇滚！',
            checkedEpisodeCnt: 12,
          ),
          const AnimeTraceAnime(animeId: 22, animeName: '孤独摇滚！'),
          const AnimeTraceAnime(
            animeId: 31,
            animeName: '只出现一次',
            checkedEpisodeCnt: 3,
          ),
        ];

    test('groups by name in first-seen order', () {
      final groups = AnimeTraceDedup.groupByName(duplicates());

      expect(groups.map((group) => group.name).toList(), <String>[
        '葬送的芙莉莲',
        '孤独摇滚！',
        '只出现一次',
      ]);
      expect(groups[0].length, 3);
      expect(groups[1].length, 2);
      expect(AnimeTraceDedup.totalCount(groups), 6);
    });

    test('pre-selects only the entries without watched progress', () {
      expect(
        AnimeTraceDedup.idsWithoutProgress(duplicates()),
        <int>{11, 13, 22},
        reason: 'id 12 and 21 have progress and must be retained',
      );
    });

    test('removing a selection keeps the last copy of a name', () {
      final groups = AnimeTraceDedup.groupByName(duplicates());
      final result = AnimeTraceDedup.removeSelected(groups, <int>{11, 13});

      expect(result.deletedIds, <int>[11, 13]);
      expect(result.removedNames, isEmpty);
      expect(result.totalCount, 4);
      expect(
        result.groups
            .firstWhere((group) => group.name == '葬送的芙莉莲')
            .animes
            .single
            .animeId,
        12,
      );
    });

    test('a name whose whole group is removed disappears', () {
      final groups = AnimeTraceDedup.groupByName(duplicates());
      final result =
          AnimeTraceDedup.removeSelected(groups, <int>{11, 12, 13, 22});

      expect(result.deletedIds, <int>[11, 12, 13, 22]);
      expect(result.removedNames, <String>['葬送的芙莉莲']);
      expect(result.totalCount, 2);
    });

    test('ids that are not in any group are not reported as deleted', () {
      final groups = AnimeTraceDedup.groupByName(duplicates());
      final result = AnimeTraceDedup.removeSelected(groups, <int>{11, 999});

      expect(result.deletedIds, <int>[11]);
      expect(result.totalCount, 5);
    });
  });

  group('lapse cover fix rules', () {
    List<AnimeTraceAnime> collection() => const <AnimeTraceAnime>[
          AnimeTraceAnime(
            animeId: 1,
            animeName: 'A',
            animeCoverUrl: 'https://cdn.agedm.org/a.jpg',
          ),
          AnimeTraceAnime(animeId: 2, animeName: 'B'),
          AnimeTraceAnime(
            animeId: 3,
            animeName: 'C',
            animeCoverUrl: '/local/cover/c.jpg',
          ),
          AnimeTraceAnime(
            animeId: 4,
            animeName: 'D',
            animeCoverUrl: 'http://cdn.agedm.org/d.jpg',
          ),
        ];

    test('only network covers are candidates', () {
      expect(
        AnimeTraceLapseCoverFix.candidates(collection())
            .map((anime) => anime.animeId)
            .toList(),
        <int>[1, 4],
      );
    });

    test('collects the covers that fail the reachability check', () {
      final lapsed = AnimeTraceLapseCoverFix.lapsedByReachability(
        collection(),
        <String, bool>{
          'https://cdn.agedm.org/a.jpg': true,
          'http://cdn.agedm.org/d.jpg': false,
        },
      );

      expect(lapsed.map((anime) => anime.animeId).toList(), <int>[4]);
    });

    test('a cover with no recorded result counts as lapsed', () {
      final lapsed = AnimeTraceLapseCoverFix.lapsedByReachability(
        collection(),
        <String, bool>{},
      );

      expect(lapsed.map((anime) => anime.animeId).toList(), <int>[1, 4]);
    });

    test('detectLapsed awaits the injected probe for every candidate', () async {
      final checked = <String>[];
      final lapsed = await AnimeTraceLapseCoverFix.detectLapsed(
        collection(),
        reachable: (url) async {
          checked.add(url);
          return url.contains('/a.jpg');
        },
      );

      expect(checked, <String>[
        'https://cdn.agedm.org/a.jpg',
        'http://cdn.agedm.org/d.jpg',
      ]);
      expect(lapsed.map((anime) => anime.animeId).toList(), <int>[4]);
    });

    test('repair batching follows the source limit of five', () async {
      expect(AnimeTraceLapseCoverFix.repairBatchSize, 5);
      final animes = <AnimeTraceAnime>[
        for (var i = 0; i < 12; i++)
          AnimeTraceAnime(animeId: i, animeName: 'A$i'),
      ];
      final batches = AnimeTraceLapseCoverFix.batches(animes);

      expect(batches.map((batch) => batch.length).toList(), <int>[5, 5, 2]);
      expect(AnimeTraceLapseCoverFix.batches(const <AnimeTraceAnime>[]), isEmpty);
      expect(
        () => AnimeTraceLapseCoverFix.batches(animes, size: 0),
        throwsArgumentError,
      );
    });
  });

  group('import rules', () {
    test('page count rounds up and reports zero for an empty total', () {
      expect(AnimeTraceImport.pageCount(0, 24), 0);
      expect(AnimeTraceImport.pageCount(24, 24), 1);
      expect(AnimeTraceImport.pageCount(25, 24), 2);
      expect(AnimeTraceImport.pageCount(48, 24), 2);
    });

    test('skips a known URL before a known name', () {
      const fallback = AnimeTraceAnime(
        animeName: '葬送的芙莉莲',
        animeUrl: 'https://www.agedm.org/detail/1234',
      );
      expect(
        AnimeTraceImport.decide(
          fallback,
          existingUrls: const <String>{'https://www.agedm.org/detail/1234'},
          existingNames: const <String>{'葬送的芙莉莲'},
        ),
        AnimeTraceImportDecision.skipDuplicateUrl,
      );
      expect(
        AnimeTraceImport.decide(
          fallback,
          existingUrls: const <String>{},
          existingNames: const <String>{'葬送的芙莉莲'},
        ),
        AnimeTraceImportDecision.skipDuplicateName,
      );
      expect(
        AnimeTraceImport.decide(
          fallback,
          existingUrls: const <String>{},
          existingNames: const <String>{'葬送的芙莉莲'},
          skipDuplicateName: false,
        ),
        AnimeTraceImportDecision.insert,
      );
      expect(
        AnimeTraceImport.decide(
          const AnimeTraceAnime(animeName: '新番'),
          existingUrls: const <String>{},
          existingNames: const <String>{},
        ),
        AnimeTraceImportDecision.insert,
      );
    });

    test('pageSlice is 1-based and empty past the end', () {
      final animes = <AnimeTraceAnime>[
        for (var i = 0; i < 5; i++) AnimeTraceAnime(animeName: 'A$i'),
      ];
      expect(
        AnimeTraceImport.pageSlice(animes, page: 1, pageSize: 2)
            .map((anime) => anime.animeName)
            .toList(),
        <String>['A0', 'A1'],
      );
      expect(
        AnimeTraceImport.pageSlice(animes, page: 3, pageSize: 2)
            .map((anime) => anime.animeName)
            .toList(),
        <String>['A4'],
      );
      expect(AnimeTraceImport.pageSlice(animes, page: 4, pageSize: 2), isEmpty);
      expect(AnimeTraceImport.pageSlice(animes, page: 0, pageSize: 2), isEmpty);
    });

    test('summary text lists only the non-zero counters', () {
      const summary = AnimeTraceImportSummary(
        skipped: 3,
        inserted: 12,
        failed: 1,
      );
      expect(summary.describe(), '3个已跳过，12个添加成功，1个添加失败');
      expect(const AnimeTraceImportSummary().describe(), '没有需要导入的内容');
    });
  });

  group('episode numbering', () {
    test('fixedEpisodeNumber honours the start number and the mode flag', () {
      const counting = AnimeTraceAnime(
        animeName: 'A',
        episodeStartNumber: 13,
      );
      expect(AnimeTraceEpisode.fixedEpisodeNumber(counting, 1), 13);
      expect(AnimeTraceEpisode.fixedEpisodeNumber(counting, 3), 15);
      expect(AnimeTraceEpisode.fixedEpisodeNumber(counting, 0), 0);

      const fromOne = AnimeTraceAnime(
        animeName: 'B',
        episodeStartNumber: 13,
        calEpisodeNumberFromOne: true,
      );
      expect(AnimeTraceEpisode.fixedEpisodeNumber(fromOne, 3), 3);
      expect(AnimeTraceEpisode.fakeStartNumber(counting), 13);
      expect(AnimeTraceEpisode.fakeStartNumber(fromOne), 1);
    });

    test('play status mapping follows the source order', () {
      expect(AnimeTracePlayStatus.fromText('已完结'), AnimeTracePlayStatus.finished);
      expect(AnimeTracePlayStatus.fromText('未开播'), AnimeTracePlayStatus.notStarted);
      expect(AnimeTracePlayStatus.fromText('连载中'), AnimeTracePlayStatus.playing);
      expect(AnimeTracePlayStatus.fromText('更新至第3集'), AnimeTracePlayStatus.playing);
      expect(AnimeTracePlayStatus.fromText('未知'), AnimeTracePlayStatus.unknown);
      expect(AnimeTracePlayStatus.fromText(''), AnimeTracePlayStatus.unknown);
    });

    test('caption and watched flag', () {
      final episode = AnimeTraceEpisode(3, startNumber: 13, dateTime: '2026-10-17');
      expect(episode.numberWithStartNumber, 15);
      expect(episode.caption, '第 15 集');
      expect(episode.isChecked(), isTrue);
      expect(AnimeTraceEpisode(3).isChecked(), isFalse);
      expect(AnimeTraceEpisode(0).isRateEpisode, isTrue);
    });
  });
}

// --------------------------------------------------------------- database ---

void _databaseTests() {
  group('AnimeTrace DAOs over real SQLite', () {
    late Directory directory;
    late _FfiAnimeTraceDatabase database;
    late AnimeTraceAnimeDao animeDao;
    late AnimeTraceEpisodeNoteDao noteDao;
    late AnimeTraceHistoryDao historyDao;

    setUp(() async {
      directory = Directory.systemTemp.createTempSync('animetrace_test_');
      database = _FfiAnimeTraceDatabase('${directory.path}/anime_trace.db');
      await database.open();
      animeDao = AnimeTraceAnimeDao(
        database,
        clock: () => DateTime.utc(2026, 10, 17, 7, 30),
      );
      noteDao = AnimeTraceEpisodeNoteDao(
        database,
        clock: () => DateTime.utc(2026, 10, 17, 8),
      );
      historyDao = AnimeTraceHistoryDao(database);
    });

    tearDown(() async {
      await database.close();
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });

    test('schema creates every table', () async {
      final rows = await database.rawQuery(
        "select name from sqlite_master where type = 'table' order by name",
      );
      final names = rows.map((row) => '${row['name']}').toSet();

      expect(names, containsAll(<String>[
        AnimeTraceSchema.animeTable,
        AnimeTraceSchema.historyTable,
        AnimeTraceSchema.episodeNoteTable,
        AnimeTraceSchema.imageTable,
        AnimeTraceSchema.labelTable,
        AnimeTraceSchema.seriesTable,
      ]));
    });

    test('anime insert round-trips every mapped field', () async {
      const anime = AnimeTraceAnime(
        animeName: '葬送的芙莉莲',
        animeEpisodeCnt: 28,
        animeDesc: '魔王被打倒之后的故事。',
        animeCoverUrl: 'https://cdn.agedm.org/cover/frieren.jpg',
        animeUrl: 'https://www.agedm.org/detail/1234',
        premiereTime: '2023-09-29',
        nameAnother: '葬送的芙莉莲',
        nameOri: '葬送のフリーレン',
        authorOri: '山田鐘人',
        area: '日本',
        category: 'TV',
        playStatus: '已完结',
        productionCompany: 'MADHOUSE',
        reviewNumber: 2,
        rate: 9,
        episodeStartNumber: 1,
        calEpisodeNumberFromOne: true,
        tagName: '收集',
      );
      final id = await animeDao.insertAnime(anime);
      expect(id, greaterThan(0));

      final stored = await animeDao.getAnimeById(id);
      expect(stored, isNotNull);
      expect(stored!.animeName, '葬送的芙莉莲');
      expect(stored.animeEpisodeCnt, 28);
      expect(stored.animeDesc, '魔王被打倒之后的故事。');
      expect(stored.animeCoverUrl, 'https://cdn.agedm.org/cover/frieren.jpg');
      expect(stored.animeUrl, 'https://www.agedm.org/detail/1234');
      expect(stored.premiereTime, '2023-09-29');
      expect(stored.nameOri, '葬送のフリーレン');
      expect(stored.area, '日本');
      expect(stored.playStatus, '已完结');
      expect(stored.productionCompany, 'MADHOUSE');
      expect(stored.reviewNumber, 2);
      expect(stored.rate, 9);
      expect(stored.calEpisodeNumberFromOne, isTrue);
      expect(stored.tagName, '收集');
      expect(stored.isCollected(), isTrue);
      expect(await animeDao.getAnimeByAnimeUrl(anime.animeUrl), isNotNull);
      expect(await animeDao.existAnimeName('葬送的芙莉莲'), isTrue);
    });

    test('duplicate names are found and cascade on delete', () async {
      final first = await animeDao.insertAnime(
        const AnimeTraceAnime(animeName: '葬送的芙莉莲', animeUrl: 'u1'),
      );
      await animeDao.insertAnime(
        const AnimeTraceAnime(animeName: '葬送的芙莉莲', animeUrl: 'u2'),
      );
      await animeDao.insertAnime(
        const AnimeTraceAnime(animeName: '孤独摇滚！', animeUrl: 'u3'),
      );

      final duplicates = await animeDao.getDupAnimes();
      expect(duplicates, hasLength(2));
      expect(duplicates.every((anime) => anime.animeName == '葬送的芙莉莲'), isTrue);

      // The episode-0 rating note and one image go with the anime.
      final noteId = await noteDao.insertRateNote(first);
      await noteDao.addImage(noteId, relativePath: 'note/rate.jpg');
      await historyDao.insertHistory(animeId: first, episodeNumber: 1);
      await animeDao.deleteAnimeById(first);

      expect(await animeDao.getAnimeById(first), isNull);
      expect(await noteDao.getImages(noteId), isEmpty);
      expect(await historyDao.getCheckedEpisodeCount(first), 0);
      expect((await animeDao.getDupAnimes()), isEmpty);
    });

    test('episode note round-trip keeps content and image order', () async {
      final animeId = await animeDao.insertAnime(
        const AnimeTraceAnime(
          animeName: '葬送的芙莉莲',
          animeUrl: 'https://www.agedm.org/detail/1234',
          animeEpisodeCnt: 28,
          episodeStartNumber: 1,
        ),
      );
      final anime = (await animeDao.getAnimeById(animeId))!;
      final episode = AnimeTraceEpisode(3, startNumber: anime.episodeStartNumber);

      expect(await noteDao.loadNote(anime, episode), isNull);

      final noteId = await noteDao.ensureNote(anime, episode);
      expect(noteId, greaterThan(0));
      expect(await noteDao.ensureNote(anime, episode), noteId,
          reason: 'ensureNote must be idempotent');

      await noteDao.saveNoteContent(noteId, "第三集：勇者之剑 ' 引号也要能存");
      await noteDao.addImage(
        noteId,
        relativePath: 'note/2026/first.jpg',
        originName: 'first.jpg',
      );
      await noteDao.addImage(noteId, relativePath: 'note/2026/second.jpg');

      final note = await noteDao.loadNote(anime, episode);
      expect(note, isNotNull);
      expect(note!.id, noteId);
      expect(note.noteContent, "第三集：勇者之剑 ' 引号也要能存");
      expect(note.episodeNumber, 3);
      expect(
        note.relativeLocalImages.map((image) => image.path).toList(),
        <String>['note/2026/first.jpg', 'note/2026/second.jpg'],
      );
      expect(note.updateTime, '2026-10-17T08:00:00.000Z');

      expect(await noteDao.getNotedEpisodeNumbers(animeId), <int>{3});
      expect(await noteDao.getEpisodeNoteCount(), 1);
      expect(await noteDao.getAnimeIdsWithRecentNotes(isRateNote: false),
          <int>[animeId]);
      expect(await noteDao.getAnimeIdsWithRecentNotes(isRateNote: true), isEmpty);

      await noteDao.deleteNote(noteId);
      expect(await noteDao.loadNote(anime, episode), isNull);
      expect(await noteDao.getEpisodeNoteCount(), 0);
    });

    test('rating notes (episode 0) are listed newest first', () async {
      final animeId = await animeDao.insertAnime(
        const AnimeTraceAnime(animeName: '葬送的芙莉莲'),
      );
      final anime = (await animeDao.getAnimeById(animeId))!;

      final first = await noteDao.ensureNote(anime, AnimeTraceEpisode(0));
      await noteDao.saveNoteContent(first, '第一遍看：很好');
      final second = await noteDao.insertRateNote(animeId);
      await noteDao.saveNoteContent(second, '第二遍看：神作');

      final notes = await noteDao.getRateNotesByAnimeId(anime);
      expect(notes.map((note) => note.noteContent).toList(),
          <String>['第二遍看：神作', '第一遍看：很好']);
      expect(await noteDao.getRateNoteCount(), 2);
      expect(await noteDao.getEpisodeNoteCount(), 0);
      expect(await noteDao.getRateNotes(limit: 1), hasLength(1));
    });

    test('history is grouped by day with min/max episode numbers', () async {
      final first = await animeDao.insertAnime(
        const AnimeTraceAnime(
          animeName: '葬送的芙莉莲',
          episodeStartNumber: 1,
        ),
      );
      final second = await animeDao.insertAnime(
        const AnimeTraceAnime(
          animeName: '孤独摇滚！',
          episodeStartNumber: 13,
        ),
      );

      // Day 1: two anime. Day 2: one anime watched twice over.
      await historyDao.insertHistory(
        animeId: first,
        episodeNumber: 1,
        date: '2026-10-15T20:00:00.000Z',
      );
      await historyDao.insertHistory(
        animeId: first,
        episodeNumber: 2,
        date: '2026-10-15T20:05:00.000Z',
      );
      await historyDao.insertHistory(
        animeId: second,
        episodeNumber: 1,
        date: '2026-10-15T21:00:00.000Z',
      );
      await historyDao.insertHistory(
        animeId: second,
        episodeNumber: 3,
        date: '2026-10-16T09:00:00.000Z',
      );
      await historyDao.insertHistory(
        animeId: second,
        episodeNumber: 5,
        date: '2026-10-16T09:30:00.000Z',
        reviewNumber: 2,
      );

      expect(await historyDao.getHistoryDayCount(), 2);
      expect(await historyDao.hasWatched(second, 3), isTrue);
      expect(await historyDao.hasWatched(second, 4), isFalse);
      expect(await historyDao.getCheckedEpisodeCount(second), 2);
      expect(await historyDao.getCheckedEpisodeCount(second, reviewNumber: 2), 1);
      expect(await historyDao.getWatchedEpisodeDates(second), <int, String>{
        1: '2026-10-15T21:00:00.000Z',
        3: '2026-10-16T09:00:00.000Z',
      });

      final groups = await historyDao.getHistoryPageable(page: 1, pageSize: 20);
      expect(groups.map((group) => group.date).toList(),
          <String>['2026-10-16', '2026-10-15']);

      final latest = groups.first;
      expect(latest.records, hasLength(2));
      final rewatch = latest.records.firstWhere(
        (record) => record.reviewNumber == 2,
      );
      expect(rewatch.anime.animeName, '孤独摇滚！');
      expect(rewatch.startEpisodeNumber, 17,
          reason: 'raw episode 5 with startNumber 13 is episode 17');
      expect(rewatch.endEpisodeNumber, 17);
      expect(rewatch.episodeRangeLabel, '第 17 集');

      final firstWatch = latest.records.firstWhere(
        (record) => record.reviewNumber == 1,
      );
      expect(firstWatch.startEpisodeNumber, 15);
      expect(firstWatch.endEpisodeNumber, 15);

      final dayOne = groups[1];
      expect(dayOne.date, '2026-10-15');
      expect(dayOne.records, hasLength(2));
      final frieren = dayOne.records.firstWhere(
        (record) => record.anime.animeName == '葬送的芙莉莲',
      );
      expect(frieren.startEpisodeNumber, 1);
      expect(frieren.endEpisodeNumber, 2);
      expect(frieren.episodeRangeLabel, '第 1-2 集');
      expect(dayOne.records.firstWhere((r) => r.anime.animeName == '孤独摇滚！')
          .startEpisodeNumber, 13);

      // Pagination: one day per page.
      final pageTwo = await historyDao.getHistoryPageable(page: 2, pageSize: 1);
      expect(pageTwo.single.date, '2026-10-15');
      expect(await historyDao.getHistoryPageable(page: 3, pageSize: 1), isEmpty);

      await historyDao.deleteHistory(second, 3);
      expect(await historyDao.hasWatched(second, 3), isFalse);
      await historyDao.deleteHistoryByAnimeId(second);
      expect(await historyDao.getCheckedEpisodeCount(second), 0);
    });

    test('pageable history honours dateLength over the full timestamp',
        () async {
      final animeId = await animeDao.insertAnime(
        const AnimeTraceAnime(animeName: 'A'),
      );
      await historyDao.insertHistory(
        animeId: animeId,
        episodeNumber: 1,
        date: '2026-10-15T20:00:00.000Z',
      );
      await historyDao.insertHistory(
        animeId: animeId,
        episodeNumber: 2,
        date: '2026-10-15T22:00:00.000Z',
      );

      final monthly = await historyDao.getHistoryPageable(dateLength: 7);
      expect(monthly, hasLength(1));
      expect(monthly.single.date, '2026-10');
      expect(monthly.single.records.single.startEpisodeNumber, 1);
      expect(monthly.single.records.single.endEpisodeNumber, 2);
      expect(await historyDao.getHistoryDayCount(dateLength: 7), 1);
    });
  });
}

// ----------------------------------------------------------- health probe ---

void _healthProbeTests() {
  group('source health probe', () {
    test('reports a measured time when the site answers HTTP 200', () async {
      final dio = Dio();
      final adapter = _FakeHttpClientAdapter(
        (options) async => ResponseBody.fromString('', 200),
      );
      dio.httpClientAdapter = adapter;
      final probe = AnimeTraceHealthProbe(
        dio: dio,
        timeout: const Duration(milliseconds: 200),
        attempts: 3,
      );

      final status = await probe.check('https://www.agedm.org');

      expect(status.connectable, isTrue);
      expect(status.needPing, isFalse);
      expect(status.pinging, isFalse);
      expect(status.time, greaterThanOrEqualTo(0));
      expect(status.label.endsWith('ms'), isTrue);
      expect(status.label, isNot('测试中...'));
      expect(adapter.calls, 1);
      expect(adapter.methods, <String>['HEAD']);
      expect(adapter.urls.single, 'https://www.agedm.org');
    });

    test('retries the configured number of times before timing out', () async {
      final dio = Dio();
      final adapter = _FakeHttpClientAdapter(
        (options) async => ResponseBody.fromString('nope', 404),
      );
      dio.httpClientAdapter = adapter;
      final probe = AnimeTraceHealthProbe(
        dio: dio,
        timeout: const Duration(milliseconds: 200),
      );

      final status = await probe.check('https://omofun.tv');

      expect(status.connectable, isFalse);
      expect(status.needPing, isFalse);
      expect(status.time, -1);
      expect(status.label, '超时');
      expect(adapter.calls, 3, reason: 'the source app allowed three pings');
    });

    test('a transport failure is a timeout, not an exception', () async {
      final dio = Dio();
      final adapter = _FakeHttpClientAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          message: 'connection refused',
        ),
      );
      dio.httpClientAdapter = adapter;
      final probe = AnimeTraceHealthProbe(
        dio: dio,
        attempts: 2,
        timeout: const Duration(milliseconds: 100),
      );

      final status = await probe.check('https://www.iyhdmm.com');

      expect(status.connectable, isFalse);
      expect(status.time, -1);
      expect(adapter.calls, 2);
    });

    test('an empty URL is never probed', () async {
      final dio = Dio();
      final adapter = _FakeHttpClientAdapter(
        (options) async => ResponseBody.fromString('', 200),
      );
      dio.httpClientAdapter = adapter;
      final probe = AnimeTraceHealthProbe(dio: dio);

      final status = await probe.check('   ');

      expect(status.needPing, isFalse);
      expect(status.connectable, isFalse);
      expect(adapter.calls, 0);
    });

    test('isReachable is the single-request cover check', () async {
      final dio = Dio();
      final adapter = _FakeHttpClientAdapter(
        (options) async => ResponseBody.fromString(
          '',
          options.path.contains('gone') ? 403 : 200,
        ),
      );
      dio.httpClientAdapter = adapter;
      final probe = AnimeTraceHealthProbe(dio: dio);

      expect(await probe.isReachable('https://cdn.agedm.org/a.jpg'), isTrue);
      expect(await probe.isReachable('https://cdn.agedm.org/gone.jpg'), isFalse);
      expect(await probe.isReachable(''), isFalse);
      expect(adapter.calls, 2);
    });
  });
}

// ------------------------------------------------------- fake dio adapter ---

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<String> methods = <String>[];
  final List<String> urls = <String>[];
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    calls++;
    methods.add(options.method);
    urls.add(options.uri.toString());
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

// ------------------------------------------------- sqlite3 FFI stand-in ----
//
// `sqflite_common_ffi` is not a host dependency and this port must not add one,
// while the sqflite plugin's method channel cannot answer inside `flutter test`.
// These bindings talk to the platform's own sqlite3 and implement the same
// `AnimeTraceExecutorDatabase` surface the production sqflite database
// implements, so the DAOs run their real SQL.
//
// NOTE: this is a deliberate test-only deviation; it must be reported.

DynamicLibrary _openSqliteLibrary() {
  if (Platform.isMacOS) {
    for (final name in const <String>[
      'libsqlite3.dylib',
      '/usr/lib/libsqlite3.dylib',
    ]) {
      try {
        return DynamicLibrary.open(name);
      } catch (_) {}
    }
  } else if (Platform.isLinux) {
    for (final name in const <String>['libsqlite3.so.0', 'libsqlite3.so']) {
      try {
        return DynamicLibrary.open(name);
      } catch (_) {}
    }
  } else if (Platform.isWindows) {
    try {
      return DynamicLibrary.open('sqlite3.dll');
    } catch (_) {}
  }
  return DynamicLibrary.process();
}

final DynamicLibrary _sqliteLibrary = _openSqliteLibrary();

typedef _OpenV2Native = Int32 Function(
  Pointer<Uint8> filename,
  Pointer<Pointer<Void>> ppDb,
  Int32 flags,
  Pointer<Uint8> zVfs,
);
typedef _OpenV2 = int Function(
  Pointer<Uint8> filename,
  Pointer<Pointer<Void>> ppDb,
  int flags,
  Pointer<Uint8> zVfs,
);

typedef _PrepareNative = Int32 Function(
  Pointer<Void> db,
  Pointer<Uint8> sql,
  Int32 nByte,
  Pointer<Pointer<Void>> ppStmt,
  Pointer<Pointer<Uint8>> pzTail,
);
typedef _Prepare = int Function(
  Pointer<Void> db,
  Pointer<Uint8> sql,
  int nByte,
  Pointer<Pointer<Void>> ppStmt,
  Pointer<Pointer<Uint8>> pzTail,
);

typedef _StepNative = Int32 Function(Pointer<Void> stmt);
typedef _Step = int Function(Pointer<Void> stmt);

typedef _FinalizeNative = Int32 Function(Pointer<Void> stmt);
typedef _Finalize = int Function(Pointer<Void> stmt);

typedef _CloseNative = Int32 Function(Pointer<Void> db);
typedef _Close = int Function(Pointer<Void> db);

typedef _ExecNative = Int32 Function(
  Pointer<Void> db,
  Pointer<Uint8> sql,
  Pointer<Void> callback,
  Pointer<Void> arg,
  Pointer<Pointer<Uint8>> errmsg,
);
typedef _Exec = int Function(
  Pointer<Void> db,
  Pointer<Uint8> sql,
  Pointer<Void> callback,
  Pointer<Void> arg,
  Pointer<Pointer<Uint8>> errmsg,
);

typedef _ErrmsgNative = Pointer<Uint8> Function(Pointer<Void> db);
typedef _Errmsg = Pointer<Uint8> Function(Pointer<Void> db);

typedef _ChangesNative = Int32 Function(Pointer<Void> db);
typedef _Changes = int Function(Pointer<Void> db);

typedef _LastRowIdNative = Int64 Function(Pointer<Void> db);
typedef _LastRowId = int Function(Pointer<Void> db);

typedef _MallocNative = Pointer<Uint8> Function(Int64 n);
typedef _Malloc = Pointer<Uint8> Function(int n);

typedef _FreeNative = Void Function(Pointer<Uint8> pointer);
typedef _Free = void Function(Pointer<Uint8> pointer);

typedef _ColumnCountNative = Int32 Function(Pointer<Void> stmt);
typedef _ColumnCount = int Function(Pointer<Void> stmt);

typedef _ColumnNameNative = Pointer<Uint8> Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnName = Pointer<Uint8> Function(Pointer<Void> stmt, int i);

typedef _ColumnTypeNative = Int32 Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnType = int Function(Pointer<Void> stmt, int i);

typedef _ColumnInt64Native = Int64 Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnInt64 = int Function(Pointer<Void> stmt, int i);

typedef _ColumnDoubleNative = Double Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnDouble = double Function(Pointer<Void> stmt, int i);

typedef _ColumnTextNative = Pointer<Uint8> Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnText = Pointer<Uint8> Function(Pointer<Void> stmt, int i);

typedef _ColumnBytesNative = Int32 Function(Pointer<Void> stmt, Int32 i);
typedef _ColumnBytes = int Function(Pointer<Void> stmt, int i);

typedef _BindNullNative = Int32 Function(Pointer<Void> stmt, Int32 i);
typedef _BindNull = int Function(Pointer<Void> stmt, int i);

typedef _BindInt64Native = Int32 Function(Pointer<Void> stmt, Int32 i, Int64 v);
typedef _BindInt64 = int Function(Pointer<Void> stmt, int i, int v);

typedef _BindDoubleNative = Int32 Function(Pointer<Void> stmt, Int32 i, Double v);
typedef _BindDouble = int Function(Pointer<Void> stmt, int i, double v);

typedef _BindTextNative = Int32 Function(
  Pointer<Void> stmt,
  Int32 i,
  Pointer<Uint8> text,
  Int32 n,
  Pointer<Void> destructor,
);
typedef _BindText = int Function(
  Pointer<Void> stmt,
  int i,
  Pointer<Uint8> text,
  int n,
  Pointer<Void> destructor,
);

final _OpenV2 _openV2 =
    _sqliteLibrary.lookupFunction<_OpenV2Native, _OpenV2>('sqlite3_open_v2');
final _Prepare _prepare =
    _sqliteLibrary.lookupFunction<_PrepareNative, _Prepare>('sqlite3_prepare_v2');
final _Step _step = _sqliteLibrary.lookupFunction<_StepNative, _Step>('sqlite3_step');
final _Finalize _finalize =
    _sqliteLibrary.lookupFunction<_FinalizeNative, _Finalize>('sqlite3_finalize');
final _Close _close = _sqliteLibrary.lookupFunction<_CloseNative, _Close>('sqlite3_close');
final _Exec _exec = _sqliteLibrary.lookupFunction<_ExecNative, _Exec>('sqlite3_exec');
final _Errmsg _errmsg =
    _sqliteLibrary.lookupFunction<_ErrmsgNative, _Errmsg>('sqlite3_errmsg');
final _Changes _changes =
    _sqliteLibrary.lookupFunction<_ChangesNative, _Changes>('sqlite3_changes');
final _LastRowId _lastRowId =
    _sqliteLibrary.lookupFunction<_LastRowIdNative, _LastRowId>(
  'sqlite3_last_insert_rowid',
);
final _Malloc _sqliteMalloc =
    _sqliteLibrary.lookupFunction<_MallocNative, _Malloc>('sqlite3_malloc');
final _Free _sqliteFree =
    _sqliteLibrary.lookupFunction<_FreeNative, _Free>('sqlite3_free');
final _ColumnCount _columnCount =
    _sqliteLibrary.lookupFunction<_ColumnCountNative, _ColumnCount>(
  'sqlite3_column_count',
);
final _ColumnName _columnName =
    _sqliteLibrary.lookupFunction<_ColumnNameNative, _ColumnName>(
  'sqlite3_column_name',
);
final _ColumnType _columnType =
    _sqliteLibrary.lookupFunction<_ColumnTypeNative, _ColumnType>(
  'sqlite3_column_type',
);
final _ColumnInt64 _columnInt64 =
    _sqliteLibrary.lookupFunction<_ColumnInt64Native, _ColumnInt64>(
  'sqlite3_column_int64',
);
final _ColumnDouble _columnDouble =
    _sqliteLibrary.lookupFunction<_ColumnDoubleNative, _ColumnDouble>(
  'sqlite3_column_double',
);
final _ColumnText _columnText =
    _sqliteLibrary.lookupFunction<_ColumnTextNative, _ColumnText>(
  'sqlite3_column_text',
);
final _ColumnBytes _columnBytes =
    _sqliteLibrary.lookupFunction<_ColumnBytesNative, _ColumnBytes>(
  'sqlite3_column_bytes',
);
final _BindNull _bindNull =
    _sqliteLibrary.lookupFunction<_BindNullNative, _BindNull>('sqlite3_bind_null');
final _BindInt64 _bindInt64 =
    _sqliteLibrary.lookupFunction<_BindInt64Native, _BindInt64>(
  'sqlite3_bind_int64',
);
final _BindDouble _bindDouble =
    _sqliteLibrary.lookupFunction<_BindDoubleNative, _BindDouble>(
  'sqlite3_bind_double',
);
final _BindText _bindText =
    _sqliteLibrary.lookupFunction<_BindTextNative, _BindText>('sqlite3_bind_text');

const int _ok = 0;
const int _row = 100;
const int _done = 101;
const int _typeInteger = 1;
const int _typeFloat = 2;
const int _typeText = 3;
const int _typeBlob = 4;

/// `SQLITE_TRANSIENT`: sqlite copies the bound bytes immediately.
final Pointer<Void> _transient = Pointer<Void>.fromAddress(-1);

Pointer<Uint8> _allocString(String value) {
  final bytes = utf8.encode(value);
  final pointer = _sqliteMalloc(bytes.length + 1);
  final view = pointer.asTypedList(bytes.length + 1);
  view.setRange(0, bytes.length, bytes);
  view[bytes.length] = 0;
  return pointer;
}

String _readCString(Pointer<Uint8> pointer) {
  final bytes = <int>[];
  var index = 0;
  while (true) {
    final byte = pointer[index];
    if (byte == 0) break;
    bytes.add(byte);
    index++;
  }
  return utf8.decode(bytes, allowMalformed: true);
}

String _quote(String identifier) => '"${identifier.replaceAll('"', '""')}"';

/// Synchronous sqlite3 wrapper: enough SQL to run the AnimeTrace schema/DAOs.
class _Sqlite3 {
  _Sqlite3._(this._db);

  final Pointer<Void> _db;
  bool _closed = false;

  static _Sqlite3 open(String path) {
    final pathPointer = _allocString(path);
    final out = _sqliteMalloc(sizeOf<Pointer<Void>>()).cast<Pointer<Void>>();
    // READWRITE | CREATE | URI
    final code = _openV2(pathPointer, out, 0x2 | 0x4 | 0x40, nullptr);
    _sqliteFree(pathPointer);
    if (code != _ok) throw StateError('sqlite3_open_v2 failed ($code)');
    return _Sqlite3._(out.value);
  }

  String get _error => _readCString(_errmsg(_db));

  void _check(int code, String sql) {
    if (code != _ok && code != _row && code != _done) {
      throw StateError('sqlite error $code: $_error\nSQL: $sql');
    }
  }

  void execute(String sql) {
    final sqlPointer = _allocString(sql);
    final outErr =
        _sqliteMalloc(sizeOf<Pointer<Uint8>>()).cast<Pointer<Uint8>>();
    final code = _exec(_db, sqlPointer, nullptr, nullptr, outErr);
    _sqliteFree(sqlPointer);
    var message = '';
    if (outErr.value != nullptr) {
      message = _readCString(outErr.value);
      _sqliteFree(outErr.value);
    }
    _sqliteFree(outErr.cast<Uint8>());
    if (code != _ok) {
      throw StateError('sqlite error $code: $message\nSQL: $sql');
    }
  }

  List<Map<String, Object?>> rawQuery(String sql, [List<Object?>? args]) {
    final statement = _prepareStatement(sql);
    try {
      _bindAll(statement, args, sql);
      final rows = <Map<String, Object?>>[];
      while (true) {
        final code = _step(statement);
        if (code == _done) break;
        if (code != _row) _check(code, sql);
        rows.add(_readRow(statement));
      }
      return rows;
    } finally {
      _finalize(statement);
    }
  }

  int _run(String sql, List<Object?>? args) {
    final statement = _prepareStatement(sql);
    try {
      _bindAll(statement, args, sql);
      final code = _step(statement);
      if (code != _done && code != _row) _check(code, sql);
      if (sql.trimLeft().toUpperCase().startsWith('INSERT')) {
        return _lastRowId(_db);
      }
      return _changes(_db);
    } finally {
      _finalize(statement);
    }
  }

  int insertMap(String table, Map<String, Object?> values) {
    final columns = values.keys.toList();
    final sql = 'INSERT INTO ${_quote(table)} '
        '(${columns.map(_quote).join(', ')}) '
        'VALUES (${List.filled(columns.length, '?').join(', ')})';
    return _run(sql, <Object?>[for (final column in columns) values[column]]);
  }

  T transaction<T>(T Function() action) {
    execute('BEGIN');
    try {
      final result = action();
      execute('COMMIT');
      return result;
    } catch (_) {
      try {
        execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _close(_db);
  }

  Pointer<Void> _prepareStatement(String sql) {
    final sqlPointer = _allocString(sql);
    final out = _sqliteMalloc(sizeOf<Pointer<Void>>()).cast<Pointer<Void>>();
    final code = _prepare(_db, sqlPointer, -1, out, nullptr);
    _sqliteFree(sqlPointer);
    if (code != _ok) {
      final message = _error;
      _sqliteFree(out.cast<Uint8>());
      throw StateError('sqlite error $code: $message\nSQL: $sql');
    }
    return out.value;
  }

  void _bindAll(Pointer<Void> statement, List<Object?>? args, String sql) {
    if (args == null) return;
    for (var index = 0; index < args.length; index++) {
      final slot = index + 1;
      final value = args[index];
      int code;
      if (value == null) {
        code = _bindNull(statement, slot);
      } else if (value is int) {
        code = _bindInt64(statement, slot, value);
      } else if (value is double) {
        code = _bindDouble(statement, slot, value);
      } else if (value is bool) {
        code = _bindInt64(statement, slot, value ? 1 : 0);
      } else if (value is Uint8List) {
        final blob = _sqliteMalloc(value.isEmpty ? 1 : value.length);
        if (value.isNotEmpty) blob.asTypedList(value.length).setAll(0, value);
        code = _bindText(statement, slot, blob, value.length, _transient);
        _sqliteFree(blob);
      } else {
        final bytes = utf8.encode(value.toString());
        final text = _sqliteMalloc(bytes.length + 1);
        final view = text.asTypedList(bytes.length + 1);
        view.setRange(0, bytes.length, bytes);
        view[bytes.length] = 0;
        code = _bindText(statement, slot, text, bytes.length, _transient);
        _sqliteFree(text);
      }
      _check(code, sql);
    }
  }

  Map<String, Object?> _readRow(Pointer<Void> statement) {
    final row = <String, Object?>{};
    final count = _columnCount(statement);
    for (var index = 0; index < count; index++) {
      final name = _readCString(_columnName(statement, index));
      switch (_columnType(statement, index)) {
        case _typeInteger:
          row[name] = _columnInt64(statement, index);
        case _typeFloat:
          row[name] = _columnDouble(statement, index);
        case _typeText:
          row[name] = _readCString(_columnText(statement, index));
        case _typeBlob:
          final length = _columnBytes(statement, index);
          final pointer = _columnText(statement, index);
          row[name] = Uint8List.fromList(
            pointer.asTypedList(length == 0 ? 1 : length).sublist(0, length),
          );
        default:
          row[name] = null;
      }
    }
    return row;
  }
}

/// [AnimeTraceExecutorDatabase] backed by the platform sqlite3 above.
class _FfiAnimeTraceDatabase implements AnimeTraceExecutorDatabase {
  _FfiAnimeTraceDatabase(this.path);

  @override
  final String path;

  _Sqlite3? _database;

  @override
  bool get isOpen => _database != null;

  _Sqlite3 get _require {
    final database = _database;
    if (database == null) throw StateError('database is closed');
    return database;
  }

  @override
  Future<void> open() async {
    final database = _Sqlite3.open(path);
    for (final statement in AnimeTraceSchema.statements) {
      database.execute(statement);
    }
    _database = database;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? args]) async =>
      _require.rawQuery(sql, args);

  @override
  Future<int> rawInsert(String sql, [List<Object?>? args]) async =>
      _require._run(sql, args);

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? args]) async =>
      _require._run(sql, args);

  @override
  Future<int> rawDelete(String sql, [List<Object?>? args]) async =>
      _require._run(sql, args);

  @override
  Future<void> execute(String sql, [List<Object?>? args]) async {
    _require.execute(sql);
  }

  @override
  Future<int> insertMap(String table, Map<String, Object?> values) async =>
      _require.insertMap(table, values);

  @override
  Future<T> transaction<T>(
    Future<T> Function(AnimeTraceExecutor txn) action,
  ) async {
    _require.execute('BEGIN');
    try {
      final result = await action(this);
      _require.execute('COMMIT');
      return result;
    } catch (_) {
      try {
        _require.execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
