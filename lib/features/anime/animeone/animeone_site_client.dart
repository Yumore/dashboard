import 'dart:convert';

import 'package:dashboard/features/anime/animeone/animeone_anime_list_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_page_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_recent_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_anime_schedule_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_info.dart';
import 'package:dashboard/features/anime/animeone/animeone_page_result.dart';
import 'package:dashboard/features/anime/animeone/animeone_recent.dart';
import 'package:dashboard/features/anime/animeone/animeone_schedule_result.dart';
import 'package:dashboard/features/anime/animeone/animeone_season.dart';
import 'package:dashboard/features/anime/animeone/animeone_url.dart';
import 'package:dashboard/features/anime/animeone/animeone_video.dart';
import 'package:dashboard/features/anime/animeone/animeone_video_source.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

/// anime1.me 站点客户端：负责请求、Cookie、令牌换取播放地址。
///
/// dio 与 http.Client 都可注入，方便测试时替换为 MockClient。
class AnimeOneSiteClient {
  AnimeOneSiteClient({Dio? dio, http.Client? httpClient, String? cookie})
    : _dio = dio ?? Dio(),
      _http = httpClient ?? http.Client(),
      cookie = cookie ?? 'videopassword=0';

  /// 站点要求的桌面端 User-Agent。
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';

  static const String _tokenEndpoint = 'https://v.anime1.me/api';

  final Dio _dio;
  final http.Client _http;
  final String cookie;

  /// 最近一次请求是否被站点拒绝（反爬 / 限流）。
  bool blocked = false;

  AnimeOneAnimeListParser get _listParser => const AnimeOneAnimeListParser();
  AnimeOneAnimePageParser get _pageParser => const AnimeOneAnimePageParser();
  AnimeOneAnimeRecentParser get _recentParser =>
      const AnimeOneAnimeRecentParser();
  AnimeOneAnimeScheduleParser get _scheduleParser =>
      const AnimeOneAnimeScheduleParser();

  Map<String, String> _headers({String? referer}) => {
    'cookie': cookie,
    'user-agent': userAgent,
    'referer': referer ?? AnimeOneUrl.domain,
  };

  /// 把字节按 UTF-8 解析成 HTML 文档。
  Document _document(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return html_parser.parse('');
    return html_parser.parse(utf8.decode(bytes, allowMalformed: true));
  }

  bool _isBlocked(int? statusCode) =>
      statusCode == 403 ||
      statusCode == 404 ||
      statusCode == 429 ||
      statusCode == 503;

  /// GET 一个页面，失败时返回空文档并把 [blocked] 置位。
  Future<Document> get(String link, {String? referer}) async {
    try {
      final response = await _dio.get<List<int>>(
        link,
        options: Options(
          headers: _headers(referer: referer),
          responseType: ResponseType.bytes,
          // 不能跟着 dio 默认抛异常，否则拿不到 403/503 这类状态码。
          validateStatus: (_) => true,
        ),
      );
      if (_isBlocked(response.statusCode)) {
        blocked = true;
        return html_parser.parse('');
      }
      return _document(response.data);
    } on DioException {
      return html_parser.parse('');
    }
  }

  /// POST 一个表单页面。
  Future<Document> post(String link, {String? body, String? referer}) async {
    try {
      final response = await _dio.post<List<int>>(
        link,
        data: body,
        options: Options(
          headers: _headers(referer: referer),
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );
      if (_isBlocked(response.statusCode)) {
        blocked = true;
        return html_parser.parse('');
      }
      return _document(response.data);
    } on DioException {
      return html_parser.parse('');
    }
  }

  /// 动画目录（animelist.json），带时间戳避免缓存。
  Future<List<AnimeOneInfo>> getAnimeList() async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    try {
      final response = await _dio.get<String>(
        '${AnimeOneUrl.domain}animelist.json?_=$stamp',
        options: Options(
          headers: _headers(),
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      if (_isBlocked(response.statusCode)) {
        blocked = true;
        return const [];
      }
      return _listParser.parseBody(response.data ?? '');
    } on DioException {
      return const [];
    }
  }

  /// 首页的“最近更新”。
  Future<List<AnimeOneRecent>> getRecent() async {
    final document = await get(AnimeOneUrl.domain);
    return _recentParser.parse(document);
  }

  /// 指定季度的新番表。
  Future<AnimeOneScheduleResult> getSchedule(AnimeOneSeason season) async {
    final document = await get(season.scheduleLink);
    return _scheduleParser.parse(document);
  }

  /// 分类页 / 单集页，page 大于 1 时使用 /page/N 链接。
  Future<AnimeOnePageResult> getPage({
    required String link,
    required int page,
  }) async {
    final target = link.contains('?cat=') ? await resolveRedirect(link) : link;
    final document = await get(
      AnimeOneUrl.paged(target, page),
      referer: target,
    );
    final result = _pageParser.parse(document);
    return AnimeOnePageResult(
      entries: result.entries,
      title: result.title,
      categoryLink: result.categoryLink ?? target,
    );
  }

  /// 跟随 ?cat= 之类的跳转，直到目标链接不再带查询串。
  Future<String> resolveRedirect(String link) async {
    if (!link.contains('?')) return link;
    var current = link;
    for (var i = 0; i < 10; i++) {
      try {
        final request = http.Request('GET', Uri.parse(current))
          ..followRedirects = false
          ..headers.addAll(_headers());
        final response = await _http.send(request);
        await response.stream.drain<void>();
        final location = response.headers['location'];
        if (location == null || location.isEmpty) return current;
        current = AnimeOneUrl.absolute(location, from: current);
        // 目标链接不再带查询串（例如 WordPress 的 ?cat=ID 跳转）时就到了终点。
        if (!current.contains('?')) return current;
      } catch (_) {
        return current;
      }
    }
    return current;
  }

  /// 令牌换播放地址：POST `d=<video.data-apireq>` 到 v.anime1.me/api。
  Future<AnimeOneVideoSource> getVideoSource(AnimeOneVideo? video) async {
    final raw = video?.video;
    if (video == null || raw == null || raw.isEmpty) {
      return const AnimeOneVideoSource();
    }
    if (!video.hasToken) {
      // 站点用协议相对地址（//v.anime1.me/...），统一补全成绝对地址。
      return AnimeOneVideoSource(url: AnimeOneUrl.absolute(raw));
    }
    try {
      final response = await _http.post(
        Uri.parse(_tokenEndpoint),
        body: 'd=$raw',
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'user-agent': userAgent,
          'referer': AnimeOneUrl.domain,
          'cookie': cookie,
        },
      );
      if (response.statusCode != 200) return const AnimeOneVideoSource();
      return _readSource(response.headers, response.body);
    } catch (_) {
      return const AnimeOneVideoSource();
    }
  }

  /// http 会把多条 set-cookie 合并成逗号分隔的一行；播放 CDN 需要 e/p/h
  /// 三个 cookie 同时带上（缺一个都会 403），所以这里取出全部 name=value。
  static String? _streamCookie(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return null;
    const attributes = {
      'expires',
      'path',
      'domain',
      'max-age',
      'secure',
      'httponly',
      'samesite',
    };
    final pairs = <String>[];
    for (final part in setCookie.split(',')) {
      final pair = part.split(';').first.trim();
      if (!pair.contains('=')) continue;
      final name = pair.split('=').first.trim().toLowerCase();
      if (attributes.contains(name)) continue;
      pairs.add(pair);
    }
    return pairs.isEmpty ? null : pairs.join('; ');
  }

  AnimeOneVideoSource _readSource(Map<String, String> headers, String body) {
    final cookie = _streamCookie(headers['set-cookie']);
    if (body.isEmpty) return AnimeOneVideoSource(cookie: cookie);
    try {
      final data = jsonDecode(body);
      if (data is! Map) return AnimeOneVideoSource(cookie: cookie);
      final streams = data['s'];
      if (streams is! List || streams.isEmpty) {
        return AnimeOneVideoSource(cookie: cookie);
      }
      final first = streams.first;
      if (first is! Map) return AnimeOneVideoSource(cookie: cookie);
      final src = '${first['src']}';
      if (src.isEmpty || src == 'null') {
        return AnimeOneVideoSource(cookie: cookie);
      }
      final url = src.contains('http') ? src : 'https:$src';
      return AnimeOneVideoSource(url: url, cookie: cookie);
    } catch (_) {
      return AnimeOneVideoSource(cookie: cookie);
    }
  }

  void close() {
    _dio.close();
    _http.close();
  }
}
