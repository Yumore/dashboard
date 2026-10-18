import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/anime/animeone/animeone_anime_list_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_page_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_recent_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_schedule_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_detail_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_history_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_latest_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_list_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_module_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_resolver.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_season.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:dashboard/features/anime/animeone/animeone_video.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// 手写 fixture：结构照抄 2026-10-17 抓取到的真实页面。
// ---------------------------------------------------------------------------

/// animelist.json：真实响应没有表头，id 为 0 的行是 anime1.pw 的推广条目。
final String animeListJson = jsonEncode(<dynamic>[
  <dynamic>[1916, '我家的弟弟們真是讓您費心了', '連載中(15)', '2026', '夏', ''],
  <dynamic>[
    0,
    '<a href="https://anime1.pw/?cat=62">關於相同研討會的染谷同學是性感女優這檔事。</a>',
    '連載中(04)',
    '2026',
    '夏',
    '桜都',
  ],
  <dynamic>[2008, '藥師少女的獨語 第三季', '連載中(50)', '2026', '秋', '喵萌奶茶屋'],
  <dynamic>[1972, '鏈鋸人 刺客篇', '全12話', '2025/2026', '2025秋/2026秋', '桜都字幕组'],
]);

/// 站点 Location 头里给的是小写百分号转义，Uri 会规范化成大写形式；
/// fixture 和断言都走同一个规范形式，避免大小写不一致。
final String categoryLink = Uri.parse(
  'https://anime1.me/category/2026%e5%b9%b4%e7%a7%8b%e5%ad%a3/'
  '%e8%97%a5%e5%b8%ab%e5%b0%91%e5%a5%b3%e7%9a%84%e7%8d%a8%e8%aa%9e-%e7%ac%ac%e4%b8%89%e5%ad%a3',
).toString();

/// 分类页：两个 hentry（第 49 集有下一集，第 50 集是最后一集）+ 一个需要密码的条目。
final String episodeHtml =
    '''
<html><body>
<div id="content" class="site-content">
<header class="page-header"><h1 class="page-title">藥師少女的獨語 第三季</h1></header>
<article id="post-30351" class="post-30351 post type-post status-publish format-standard hentry category-2008">
  <div class="entry-image"><a href=" https://anime1.me/30351 " rel="bookmark"></a></div>
  <header class="entry-header">
    <h2 class="entry-title"><a href="https://anime1.me/30351" rel="bookmark">藥師少女的獨語 第三季 [49]</a></h2>
    <div class="entry-meta"><span class="posted-on"><a href="https://anime1.me/30351" rel="bookmark"><time class="entry-date published updated" datetime="2026-10-06T02:03:13+08:00">2026-10-06</time></a></span></div>
  </header>
  <div class="entry-content">
    <div class="vjscontainer"><video id="vjs-UJhK9" data-apireq="%7B%22c%22%3A%222008%22%2C%22e%22%3A%2249%22%2C%22t%22%3A1792194059%2C%22s%22%3A%22062e709cb822489cfe8d9a0250a3b5d6%22%7D" data-vid="UJhK9" data-tserver="pt2" class="video-js vjs-big-play-centered" poster="https://sta.anicdn.com/playerImg/8.jpg" controls preload="none"></video></div>
    <p><a href="/?cat=2008">全集連結</a><br><a href="/?p=30356">下一集</a></p>
  </div>
  <footer class="entry-footer"><span class="cat-links">分類: <a href="$categoryLink" rel="category tag">藥師少女的獨語 第三季</a></span><span class="comments-link"><a href="https://anime1.me/30351#respond">則留言</a></span></footer>
</article>
<article id="post-30356" class="post-30356 post type-post status-publish format-standard hentry category-2008">
  <header class="entry-header"><h2 class="entry-title"><a href="https://anime1.me/30356" rel="bookmark">藥師少女的獨語 第三季 [50]</a></h2>
  <span class="posted-on"><time class="entry-date published updated" datetime="2026-10-13T02:03:13+08:00">2026-10-13</time></span></header>
  <div class="entry-content">
    <div class="vjscontainer"><video data-apireq="%7B%22c%22%3A%222008%22%2C%22e%22%3A%2250%22%7D"></video></div>
    <p><a href="/?cat=2008">全集連結</a><br><a href="/?p=" disabled onclick="return false;">下一集</a></p>
  </div>
</article>
<article id="post-30400" class="post-30400 hentry category-2008">
  <h2 class="entry-title"><a href="/30400" rel="bookmark">需要密碼的劇集 [01]</a></h2>
  <div class="entry-date">2026-10-16</div>
  <div class="entry-content"><div class="acpwd-container"><input type="password" name="pwd"></div></div>
</article>
</div>
</body></html>
''';

/// 第二页：只有一集，用于翻页测试。
const String episodePage2Html = '''
<html><body><h1 class="page-title">藥師少女的獨語 第三季</h1>
<article class="post-30350 hentry category-2008">
  <header class="entry-header"><h2 class="entry-title"><a href="https://anime1.me/30350" rel="bookmark">藥師少女的獨語 第三季 [48]</a></h2>
  <span class="posted-on"><time class="entry-date published updated" datetime="2026-09-29T02:03:13+08:00">2026-09-29</time></span></header>
  <div class="entry-content"><div class="vjscontainer"><video data-apireq="%7B%22c%22%3A%222008%22%2C%22e%22%3A%2248%22%7D"></video></div>
  <p><a href="/?cat=2008">全集連結</a><br><a href="/?p=30351">下一集</a></p></div>
</article>
</body></html>
''';

/// 只有密码条目的页面：没有可播放线路。
const String passwordOnlyHtml = '''
<html><body><h1 class="page-title">需要密碼的劇集</h1>
<article class="post-30400 hentry category-2008">
  <h2 class="entry-title"><a href="/30400" rel="bookmark">需要密碼的劇集 [01]</a></h2>
  <div class="entry-date">2026-10-16</div>
  <div class="entry-content"><div class="acpwd-container"><input type="password" name="pwd"></div></div>
</article></body></html>
''';

/// 首页侧栏“近期更新”。
const String homeHtml = '''
<html><body>
<div id="secondary" class="widget-area" role="complementary">
  <section id="search-2" class="widget widget_search"><form class="search-form" action="https://anime1.me/"><input type="search" name="s"></form></section>
  <section id="custom_html-4" class="widget_text widget widget_custom_html"><div class="textwidget custom-html-widget"><div id="ad-3"></div></div></section>
  <section id="recent-posts-6" class="widget widget_recent_entries"><h3 class="widget-title">近期更新</h3><ul><li><a href="https://anime1.me/30386">我家的弟弟們真是讓您費心了 [15]</a></li><li><a href="https://anime1.me/30385">螢火蟲的出嫁 [02]</a></li><li><a href="https://anime1.me/30384">桃源暗鬼～日光·華嚴瀑布篇～ [03]</a></li></ul></section>
</div>
</body></html>
''';

/// 新番表：第一行以周日开头，第二列是没有链接的纯文本。
const String scheduleHtml = '''
<html><body>
<h2 class="entry-title">2026年夏季新番</h2>
<table style="font-size: 12px;" id="twentysixsummer">
  <thead><tr><th colspan="7">2026年夏季(7-9月)新番</th></tr><tr><th>日</th><th>一</th><th>二</th><th>三</th><th>四</th><th>五</th><th>六</th></tr></thead>
  <tbody><tr>
    <td><a href="/?cat=1956">Let’s Go 怪奇組</a></td>
    <td>北斗之拳 拳王軍雜兵們的輓歌</td>
    <td><a href="/?cat=1940">感謝對戰。～大小姐才不玩格鬥遊戲～</a></td>
    <td><a href="/?cat=1957">女主角？聖女？都不對，我是雜役女僕（自豪）！</a></td>
    <td><a href="/?cat=1914">令和妖神斑小姐</a></td>
    <td><a href="/?cat=1915">畫完這個再去死</a></td>
    <td><a href="/?cat=1921">無職轉生III～到了異世界就拿出真本事～ (第三季)</a></td>
  </tr></tbody>
</table>
</body></html>
''';

/// 令牌换源的真实响应：src 是协议相对地址，三条 cookie 缺一不可。
const String tokenJson =
    '{"s":[{"src":"//hinata.v.anime1.me/1916/15b.mp4","type":"video/mp4"}]}';
const String tokenJwt =
    'eyJpc3MiOiJhbmltZTEubWUiLCJleHAiOjE3OTIyMjI5NjMwMDAsInN1YiI6Ii8xOTE2LzE1Yi5tcDQifQ';
const String tokenCookieHeader =
    'e=1792222963; expires=Sat, 17 Oct 2026 07:42:43 GMT; Max-Age=28799; '
    'path=/1916/15b.mp4; domain=.v.anime1.me; secure; HttpOnly, '
    'p=$tokenJwt; expires=Sat, 17 Oct 2026 07:42:43 GMT; Max-Age=28799; '
    'path=/1916/15b.mp4; domain=.v.anime1.me; secure; HttpOnly, '
    'h=srXegULIIyist16_RQuQ3A; expires=Sat, 17 Oct 2026 07:42:43 GMT; '
    'Max-Age=28799; path=/1916/15b.mp4; domain=.v.anime1.me; secure; HttpOnly';

Document document(String html) => html_parser.parse(html);
Document htmlResponse(String body) =>
    document(http.Response.bytes(utf8.encode(body), 200).body);

/// dio 没有官方的 mock adapter，这里用最小的 HttpClientAdapter 桩件。
class StubDioAdapter implements HttpClientAdapter {
  StubDioAdapter(this.resolve, {this.statusCode = 200});

  final String Function(Uri uri) resolve;
  final int statusCode;
  final List<Uri> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    final body = resolve(options.uri);
    if (body.isEmpty) {
      return ResponseBody.fromString('', 404, headers: _headers);
    }
    return ResponseBody.fromString(body, statusCode, headers: _headers);
  }

  static const Map<String, List<String>> _headers = {
    Headers.contentTypeHeader: ['text/html; charset=utf-8'],
  };

  @override
  void close({bool force = false}) {}
}

/// 一个覆盖站点全部入口的假客户端。
({
  AnimeOneSiteClient client,
  StubDioAdapter dio,
  List<http.Request> httpRequests,
})
buildClient({
  String? animeList,
  String? episode,
  String? page2,
  String? home,
  String? schedule,
  int pageStatus = 200,
  http.Response Function(http.Request request)? httpHandler,
}) {
  final dioAdapter = StubDioAdapter((uri) {
    final path = Uri.decodeFull(uri.path);
    if (path.endsWith('animelist.json')) {
      return animeList ?? animeListJson;
    }
    if (path.endsWith('/page/2')) {
      return page2 ?? episodePage2Html;
    }
    if (path.contains('/category/')) {
      return episode ?? episodeHtml;
    }
    if (path == '/') {
      return home ?? homeHtml;
    }
    if (path.contains('新番')) {
      return schedule ?? scheduleHtml;
    }
    // 单集页（例如 /30351）也走分类页的解析逻辑。
    return episode ?? episodeHtml;
  }, statusCode: pageStatus);
  final dio = Dio()..httpClientAdapter = dioAdapter;
  final requests = <http.Request>[];
  final httpClient = MockClient((request) async {
    requests.add(request);
    if (httpHandler != null) return httpHandler(request);
    if (request.url.query.contains('cat=')) {
      return http.Response('', 301, headers: {'location': categoryLink});
    }
    return http.Response('not found', 404);
  });
  return (
    client: AnimeOneSiteClient(
      dio: dio,
      httpClient: httpClient,
      cookie: 'videopassword=0',
    ),
    dio: dioAdapter,
    httpRequests: requests,
  );
}

http.Response tokenResponse({int status = 200, bool withCookies = true}) =>
    http.Response(
      status == 200 ? tokenJson : 'error',
      status,
      headers: {
        'content-type': 'application/json',
        if (withCookies) 'set-cookie': tokenCookieHeader,
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnimeOneUrl', () {
    test('builds the ?cat link used by the catalogue', () {
      expect(AnimeOneUrl.category(2008), 'https://anime1.me/?cat=2008');
    });

    test('resolves relative and protocol-relative hrefs', () {
      expect(AnimeOneUrl.absolute('/?p=30356'), 'https://anime1.me/?p=30356');
      expect(
        AnimeOneUrl.absolute('//hinata.v.anime1.me/1916/15b.mp4'),
        'https://hinata.v.anime1.me/1916/15b.mp4',
      );
      expect(
        AnimeOneUrl.absolute(' https://anime1.me/30351 '),
        'https://anime1.me/30351',
      );
      expect(AnimeOneUrl.absolute(null), '');
      expect(AnimeOneUrl.absolute('https://anime1.me/'), 'https://anime1.me/');
    });

    test('only appends /page/N after the first page', () {
      const link = 'https://anime1.me/category/2026年秋季/藥師少女的獨語-第三季';
      expect(AnimeOneUrl.paged(link, 1), link);
      expect(
        AnimeOneUrl.paged(link, 3),
        'https://anime1.me/category/2026年秋季/藥師少女的獨語-第三季/page/3',
      );
      expect(
        AnimeOneUrl.paged('$link/', 2),
        'https://anime1.me/category/2026年秋季/藥師少女的獨語-第三季/page/2',
      );
    });
  });

  group('AnimeOneSeason', () {
    test('computes the season name and links for the date', () {
      final season = AnimeOneSeason(DateTime(2026, 10, 17));
      expect(season.name, '2026年秋季新番');
      expect(season.scheduleLink, 'https://anime1.me/2026年秋季新番');
      expect(season.categoryLink, 'https://anime1.me/category/2026年秋季');
      expect(season.toString(), '2026年秋季新番');
    });

    test('lists the type filters and the last four quarters', () {
      final filters = AnimeOneSeason(DateTime(2026, 10, 17)).quickFilters();
      expect(filters.map((f) => f.label).toList(), [
        '連載中',
        '劇場版',
        'OVA',
        'OAD',
        '2026 秋季',
        '2026 夏季',
        '2026 春季',
        '2026 冬季',
      ]);
      expect(filters.map((f) => f.value).toList(), [
        '連載中',
        '劇場版',
        'OVA',
        'OAD',
        '2026秋',
        '2026夏',
        '2026春',
        '2026冬',
      ]);
    });
  });

  group('AnimeOneAnimeListParser', () {
    test('parses real animelist.json rows and skips promoted id 0 rows', () {
      final list = const AnimeOneAnimeListParser().parseBody(animeListJson);
      expect(list, hasLength(3));

      final first = list.first;
      expect(first.name, '我家的弟弟們真是讓您費心了');
      expect(first.link, 'https://anime1.me/?cat=1916');
      expect(first.episode, '連載中(15)');
      expect(first.year, '2026');
      expect(first.season, '夏');
      expect(first.subtitle, '');
      expect(first.meta, '連載中(15) · 2026夏');
      expect(first.contains('弟弟'), isTrue);
      expect(first.contains('2026夏'), isTrue);
      expect(first.contains('桜都'), isFalse);

      final second = list[1];
      expect(second.name, '藥師少女的獨語 第三季');
      expect(second.link, 'https://anime1.me/?cat=2008');
      expect(second.meta, '連載中(50) · 2026秋 · 喵萌奶茶屋');

      final third = list[2];
      expect(third.name, '鏈鋸人 刺客篇');
      expect(third.year, '2025/2026');
      expect(third.season, '2025秋/2026秋');
      expect(third.contains('2025/2026'), isTrue);
    });

    test('parses the same rows through the HTML document path', () {
      final list = const AnimeOneAnimeListParser().parse(
        document(
          '[[1916,"我家的弟弟們真是讓您費心了","連載中(15)","2026","夏",""]]',
        ),
      );
      expect(list.single.link, 'https://anime1.me/?cat=1916');
      expect(list.single.name, '我家的弟弟們真是讓您費心了');
    });

    test('returns nothing for an empty catalogue', () {
      const parser = AnimeOneAnimeListParser();
      expect(parser.parseBody(''), isEmpty);
      expect(parser.parseBody('[]'), isEmpty);
      expect(parser.parse(document('[]')), isEmpty);
      expect(parser.parse(document('')), isEmpty);
    });

    test('rejects a body that is not a JSON list', () {
      const parser = AnimeOneAnimeListParser();
      expect(() => parser.parseBody('{"a":1}'), returnsNormally);
      expect(parser.parseBody('{"a":1}'), isEmpty);
      expect(() => parser.parseBody('oops{'), throwsFormatException);
    });
  });

  group('AnimeOneAnimePageParser', () {
    test('parses hentry entries, token video, anchors and category link', () {
      final result = const AnimeOneAnimePageParser().parse(
        document(episodeHtml),
      );
      expect(result.title, '藥師少女的獨語 第三季');
      expect(result.categoryLink, categoryLink);
      expect(result.entries, hasLength(3));

      final first = result.entries.first;
      expect(first.name, '藥師少女的獨語 第三季 [49]');
      expect(first.link, 'https://anime1.me/30351');
      expect(first.formattedName(), '[49] 藥師少女的獨語 第三季');
      expect(first.postDate, '2026-10-06');
      expect(first.enhancedDate(DateTime(2026, 10, 9)), '2026-10-06 | 3天前');
      expect(first.enhancedDate(DateTime(2026, 10, 20)), '2026-10-06 | 2周前');
      expect(first.video?.video, startsWith('%7B%22'));
      expect(first.video?.hasToken, isTrue);
      expect(first.video?.isYoutube, isFalse);
      expect(first.allEpisodes, 'https://anime1.me/?cat=2008');
      expect(first.nextEpisode, 'https://anime1.me/?p=30356');
      expect(first.hasNextEpisode(), isTrue);
      expect(first.needPassword(), isFalse);
    });

    test('treats /?p= as the end of the series', () {
      final result = const AnimeOneAnimePageParser().parse(
        document(episodeHtml),
      );
      final last = result.entries[1];
      expect(last.name, '藥師少女的獨語 第三季 [50]');
      expect(last.nextEpisode, 'https://anime1.me/?p=');
      expect(last.hasNextEpisode(), isFalse);
      expect(last.needPassword(), isFalse);
    });

    test('flags entries that need a password and drops nothing', () {
      final result = const AnimeOneAnimePageParser().parse(
        document(episodeHtml),
      );
      final locked = result.entries[2];
      expect(locked.name, '需要密碼的劇集 [01]');
      expect(locked.link, 'https://anime1.me/30400');
      expect(locked.needPassword(), isTrue);
      expect(locked.video, isNull);
      expect(locked.enhancedDate(DateTime(2026, 10, 16)), '2026-10-16 | 今天');
    });

    test('returns an empty page instead of throwing on unknown markup', () {
      final result = const AnimeOneAnimePageParser().parse(
        document('<html><body><p>Cloudflare error 1020</p></body></html>'),
      );
      expect(result.entries, isEmpty);
      expect(result.title, '');
      expect(result.categoryLink, isNull);
    });
  });

  group('AnimeOneAnimeRecentParser', () {
    test('reads the sidebar recent-updates widget', () {
      final list = const AnimeOneAnimeRecentParser().parse(document(homeHtml));
      expect(list, hasLength(3));
      expect(list.first.name, '我家的弟弟們真是讓您費心了 [15]');
      expect(list.first.link, 'https://anime1.me/30386');
      expect(list.last.name, '桃源暗鬼～日光·華嚴瀑布篇～ [03]');
      expect(list.last.link, 'https://anime1.me/30384');
    });

    test('returns nothing when the widget is missing', () {
      expect(
        const AnimeOneAnimeRecentParser().parse(document('<html></html>')),
        isEmpty,
      );
    });
  });

  group('AnimeOneAnimeScheduleParser', () {
    test('maps the Sunday-first table onto DateTime.weekday', () {
      final result = const AnimeOneAnimeScheduleParser().parse(
        document(scheduleHtml),
      );
      expect(result.schedules, hasLength(7));
      expect(result.video, isNull);

      final sunday = result.schedules.first;
      expect(sunday.weekday, 7);
      expect(sunday.name, 'Let’s Go 怪奇組');
      expect(sunday.link, 'https://anime1.me/?cat=1956');

      final monday = result.schedules[1];
      expect(monday.weekday, 1);
      expect(monday.name, '北斗之拳 拳王軍雜兵們的輓歌');
      expect(monday.link, '');

      expect(result.schedules.last.weekday, 6);
      expect(result.schedules.last.name, contains('無職轉生III'));
    });

    test('returns an empty schedule without a table', () {
      final result = const AnimeOneAnimeScheduleParser().parse(
        document('<html><body>404</body></html>'),
      );
      expect(result.schedules, isEmpty);
    });
  });

  group('AnimeOneSiteClient', () {
    test(
      'getAnimeList hits animelist.json with a cache busting stamp',
      () async {
        final harness = buildClient();
        addTearDown(harness.client.close);

        final list = await harness.client.getAnimeList();

        expect(list, hasLength(3));
        expect(harness.dio.requests, hasLength(1));
        final uri = harness.dio.requests.single;
        expect(uri.host, 'anime1.me');
        expect(uri.path, '/animelist.json');
        expect(uri.query, startsWith('_='));
      },
    );

    test('getPage resolves the ?cat redirect and pages with /page/N', () async {
      final harness = buildClient(
        httpHandler: (request) =>
            http.Response('', 301, headers: {'location': categoryLink}),
      );
      addTearDown(harness.client.close);

      final page1 = await harness.client.getPage(
        link: 'https://anime1.me/?cat=2008',
        page: 1,
      );
      expect(harness.httpRequests, hasLength(1));
      expect(
        harness.httpRequests.single.url.toString(),
        'https://anime1.me/?cat=2008',
      );
      expect(page1.entries, hasLength(3));
      expect(page1.title, '藥師少女的獨語 第三季');
      expect(page1.categoryLink, categoryLink);
      expect(harness.dio.requests.single.toString(), categoryLink);

      final page2 = await harness.client.getPage(link: categoryLink, page: 2);
      expect(harness.dio.requests, hasLength(2));
      expect(harness.dio.requests.last.toString(), '$categoryLink/page/2');
      expect(page2.entries.single.name, '藥師少女的獨語 第三季 [48]');
      expect(page2.categoryLink, categoryLink);
    });

    test('follows redirects until the target has no query string', () async {
      final harness = buildClient(
        httpHandler: (request) =>
            http.Response('', 301, headers: {'location': categoryLink}),
      );
      addTearDown(harness.client.close);

      expect(
        await harness.client.resolveRedirect('https://anime1.me/?cat=2008'),
        categoryLink,
      );
      expect(await harness.client.resolveRedirect(categoryLink), categoryLink);
    });

    test('flags blocked responses and returns an empty page', () async {
      final harness = buildClient(pageStatus: 503);
      addTearDown(harness.client.close);

      final page = await harness.client.getPage(link: categoryLink, page: 1);
      expect(page.entries, isEmpty);
      expect(harness.client.blocked, isTrue);
    });

    test('keeps going when the site returns junk markup', () async {
      final harness = buildClient(episode: '<html>502 Bad Gateway</html>');
      addTearDown(harness.client.close);

      final page = await harness.client.getPage(link: categoryLink, page: 1);
      expect(page.entries, isEmpty);
      expect(page.title, '');
      expect(page.categoryLink, categoryLink);
      expect(harness.client.blocked, isFalse);
    });

    test('getRecent reads the home page sidebar', () async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      final list = await harness.client.getRecent();

      expect(harness.dio.requests.single.toString(), 'https://anime1.me/');
      expect(list, hasLength(3));
      expect(list.first.link, 'https://anime1.me/30386');
    });

    test('getSchedule loads the season page', () async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      final result = await harness.client.getSchedule(
        AnimeOneSeason(DateTime(2026, 7, 1)),
      );

      expect(
        Uri.decodeFull(harness.dio.requests.single.path),
        '/2026年夏季新番',
      );
      expect(result.schedules, hasLength(7));
    });

    test(
      'getVideoSource posts the token and keeps every stream cookie',
      () async {
        final harness = buildClient(httpHandler: (request) => tokenResponse());
        addTearDown(harness.client.close);

        final source = await harness.client.getVideoSource(
          const AnimeOneVideo('%7B%22c%22%3A%222008%22%7D'),
        );

        final request = harness.httpRequests.single;
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://v.anime1.me/api');
        expect(
          request.headers['content-type'],
          'application/x-www-form-urlencoded',
        );
        expect(request.body, 'd=%7B%22c%22%3A%222008%22%7D');
        expect(source.available, isTrue);
        expect(source.url, 'https://hinata.v.anime1.me/1916/15b.mp4');
        expect(
          source.cookie,
          'e=1792222963; p=$tokenJwt; h=srXegULIIyist16_RQuQ3A',
        );
      },
    );

    test('getVideoSource gives up when the token endpoint fails', () async {
      final harness = buildClient(
        httpHandler: (request) =>
            tokenResponse(status: 403, withCookies: false),
      );
      addTearDown(harness.client.close);

      final source = await harness.client.getVideoSource(
        const AnimeOneVideo('%7B%22c%22%3A%222008%22%7D'),
      );

      expect(source.available, isFalse);
      expect(source.cookie, isNull);
    });

    test('getVideoSource passes direct sources through untouched', () async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      final direct = await harness.client.getVideoSource(
        const AnimeOneVideo('https://v.anime1.me/embed/abc'),
      );
      final relative = await harness.client.getVideoSource(
        const AnimeOneVideo('//hinata.v.anime1.me/1916/15b.mp4'),
      );
      final nothing = await harness.client.getVideoSource(null);

      expect(direct.url, 'https://v.anime1.me/embed/abc');
      expect(relative.url, 'https://hinata.v.anime1.me/1916/15b.mp4');
      expect(nothing.available, isFalse);
      expect(harness.httpRequests, isEmpty);
    });
  });

  group('AnimeOneWatchStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('round-trips a record through SharedPreferences', () async {
      final store = AnimeOneWatchStore();
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30351',
          episodeName: '[49] 藥師少女的獨語 第三季',
          positionSec: 300,
          durationSec: 1500,
          updatedAt: DateTime(2026, 10, 17, 12),
        ),
      );

      final reloaded = AnimeOneWatchStore();
      await reloaded.load();

      expect(reloaded.isLoaded, isTrue);
      expect(reloaded.entries, hasLength(1));
      final entry = reloaded.entries.single;
      expect(entry.episodeLink, 'https://anime1.me/30351');
      expect(entry.episodeName, '[49] 藥師少女的獨語 第三季');
      expect(entry.positionSec, 300);
      expect(entry.durationSec, 1500);
      expect(entry.done, isFalse);
      expect(entry.progress, closeTo(0.2, 1e-9));
      expect(entry.progressLabel, '20%');
      expect(entry.updatedAt, DateTime(2026, 10, 17, 12));
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(AnimeOneWatchStore.storageKey),
        contains('30351'),
      );
    });

    test('updates progress and marks a long episode as done', () async {
      final store = AnimeOneWatchStore();
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30351',
          episodeName: '[49]',
          durationSec: 1500,
        ),
      );
      await store.updatePosition('https://anime1.me/30351', 300);
      expect(store.entries.single.positionSec, 300);
      expect(store.entries.single.done, isFalse);

      await store.updatePosition('https://anime1.me/30351', 1400);
      expect(store.entries.single.done, isTrue);
      expect(store.entries.single.progressLabel, '93%');

      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30350',
          episodeName: '[48]',
        ),
      );
      await store.updatePosition('/30350', AnimeOneWatchStore.doneThresholdSec);
      final short = store.entryFor('https://anime1.me/30350');
      expect(short?.done, isTrue);
      expect(short?.progressLabel, '已看完');
    });

    test('replaces the same episode instead of duplicating it', () async {
      final store = AnimeOneWatchStore();
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30351',
          episodeName: '第一版',
          updatedAt: DateTime(2026, 10, 17, 10),
        ),
      );
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: '/30351',
          episodeName: '第二版',
          updatedAt: DateTime(2026, 10, 17, 11),
        ),
      );

      expect(store.entries, hasLength(1));
      expect(store.entries.single.episodeName, '第二版');
      expect(store.entryFor('/30351')?.episodeName, '第二版');
    });

    test('sorts the newest record first and clears everything', () async {
      final store = AnimeOneWatchStore();
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30350',
          episodeName: '较早',
          updatedAt: DateTime(2026, 10, 16),
        ),
      );
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30351',
          episodeName: '最新',
          updatedAt: DateTime(2026, 10, 17),
        ),
      );

      expect(store.entries.first.episodeName, '最新');
      expect(store.entryFor('https://anime1.me/30350')?.episodeName, '较早');

      await store.clear();
      expect(store.entries, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AnimeOneWatchStore.storageKey), '[]');
    });
  });

  group('AnimeOnePlaybackResolver', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('resolves a token stream with the full cookie set', () async {
      final harness = buildClient(httpHandler: (request) => tokenResponse());
      addTearDown(harness.client.close);

      final playback = await AnimeOnePlaybackResolver(
        harness.client,
      ).resolve('https://anime1.me/30351');

      expect(playback.title, '[49] 藥師少女的獨語 第三季');
      expect(playback.page, Uri.parse('https://anime1.me/30351'));
      expect(playback.sources, hasLength(1));
      expect(
        playback.sources.single.url,
        Uri.parse('https://hinata.v.anime1.me/1916/15b.mp4'),
      );
      expect(playback.sources.single.label, '默认');
      expect(playback.sources.single.headers, {
        'referer': 'https://anime1.me/',
        'user-agent': AnimeOneSiteClient.userAgent,
        'cookie':
            'videopassword=0; e=1792222963; p=$tokenJwt; '
            'h=srXegULIIyist16_RQuQ3A',
      });
      expect(playback.previous, isNull);
      expect(playback.next, Uri.parse('https://anime1.me/?p=30356'));
    });

    test('refuses a page that only has a password box', () async {
      final harness = buildClient(episode: passwordOnlyHtml);
      addTearDown(harness.client.close);

      expect(
        () => AnimeOnePlaybackResolver(
          harness.client,
        ).resolve('https://anime1.me/30400'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '该剧集暂无可用播放地址',
          ),
        ),
      );
    });

    test('reports a broken token endpoint', () async {
      final harness = buildClient(
        httpHandler: (request) =>
            tokenResponse(status: 500, withCookies: false),
      );
      addTearDown(harness.client.close);

      expect(
        () => AnimeOnePlaybackResolver(
          harness.client,
        ).resolve('https://anime1.me/30351'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            '视频源解析失败',
          ),
        ),
      );
    });
  });

  group('screens', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('latest page lists the recent updates', (tester) async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneLatestPage(
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('我家的弟弟們真是讓您費心了 [15]'), findsOneWidget);
      expect(find.text('螢火蟲的出嫁 [02]'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('latest page explains a blocked response', (tester) async {
      final harness = buildClient(pageStatus: 503);
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneLatestPage(
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('访问被站点拒绝，请稍后再试'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('catalogue page searches and filters', (tester) async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneListPage(
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('我家的弟弟們真是讓您費心了'), findsOneWidget);
      expect(find.text('藥師少女的獨語 第三季'), findsOneWidget);
      expect(find.text('鏈鋸人 刺客篇'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '藥師');
      await tester.pumpAndSettle();
      expect(find.text('藥師少女的獨語 第三季'), findsOneWidget);
      expect(find.text('鏈鋸人 刺客篇'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, '連載中'));
      await tester.pumpAndSettle();
      expect(find.text('鏈鋸人 刺客篇'), findsNothing);
      expect(find.text('我家的弟弟們真是讓您費心了'), findsOneWidget);

      await tester.ensureVisible(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('鏈鋸人 刺客篇'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '不存在的动画');
      await tester.pumpAndSettle();
      expect(find.text('没有找到相关动画'), findsOneWidget);
    });

    testWidgets('detail page pages through the category', (tester) async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneDetailPage(
            link: 'https://anime1.me/?cat=2008',
            seasonal: true,
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('藥師少女的獨語 第三季'), findsOneWidget);
      expect(find.text('[49] 藥師少女的獨語 第三季'), findsOneWidget);
      expect(find.text('全集'), findsWidgets);
      expect(find.text('下一集'), findsWidgets);

      final state = tester.state<AnimeOneDetailPageState>(
        find.byType(AnimeOneDetailPage),
      );
      expect(state.entries, hasLength(3));

      // 直接 await 会把请求卡在 fake async 的定时器上，
      // 用 runAsync 让 dio 的 future 真正跑完再 pump 一帧。
      await tester.runAsync(state.nextPage);
      await tester.pump();

      expect(state.page, 2);
      expect(state.entries, hasLength(4));
      expect(find.text('[48] 藥師少女的獨語 第三季'), findsOneWidget);
      expect(harness.dio.requests.last.path, endsWith('/page/2'));
      expect(harness.dio.requests.last.toString(), '$categoryLink/page/2');
    });

    testWidgets('detail page reports an empty category', (tester) async {
      final harness = buildClient(episode: '<html><body></body></html>');
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneDetailPage(
            link: 'https://anime1.me/?cat=2008',
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('没有找到相关结果'), findsOneWidget);
    });

    testWidgets('schedule page groups episodes by weekday', (tester) async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneSchedulePage(
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in ['周一', '周二', '周三', '周四', '周五', '周六', '周日']) {
        expect(find.text(label), findsOneWidget);
      }

      final state = tester.state<AnimeOneSchedulePageState>(
        find.byType(AnimeOneSchedulePage),
      );
      expect(state.schedules, hasLength(7));
      expect(
        state.schedulesFor(7).map((item) => item.name),
        contains('Let’s Go 怪奇組'),
      );
      expect(
        state.schedulesFor(1).map((item) => item.name),
        contains('北斗之拳 拳王軍雜兵們的輓歌'),
      );
      expect(
        state.schedulesFor(3).single.name,
        '女主角？聖女？都不對，我是雜役女僕（自豪）！',
      );
      expect(state.schedulesFor(4).single.name, '令和妖神斑小姐');
    });

    testWidgets('history page shows progress and clears on confirm', (
      tester,
    ) async {
      final store = AnimeOneWatchStore();
      await store.save(
        AnimeOneWatchEntry(
          episodeLink: 'https://anime1.me/30351',
          episodeName: '[49] 藥師少女的獨語 第三季',
          positionSec: 300,
          durationSec: 1500,
          updatedAt: DateTime(2026, 10, 17),
        ),
      );
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneHistoryPage(client: harness.client, watchStore: store),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('[49] 藥師少女的獨語 第三季'), findsOneWidget);
      expect(find.text('05:00 / 25:00 · 20%'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();
      expect(find.text('确定要删除全部观看记录吗？'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.text('还没有观看记录'), findsOneWidget);
    });

    testWidgets('playback page surfaces the resolver error', (tester) async {
      final harness = buildClient(episode: passwordOnlyHtml);
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOnePlaybackPage(
            link: 'https://anime1.me/30400',
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('该剧集暂无可用播放地址'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('module page offers every entry point', (tester) async {
      final harness = buildClient();
      addTearDown(harness.client.close);

      await tester.pumpWidget(
        MaterialApp(
          home: AnimeOneModulePage(
            client: harness.client,
            watchStore: AnimeOneWatchStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('最近更新'), findsOneWidget);
      expect(find.text('动画目录'), findsOneWidget);
      expect(find.text('观看记录'), findsOneWidget);
      expect(find.text('本季分类'), findsOneWidget);
      expect(find.textContaining('年'), findsWidgets);
    });
  });
}
