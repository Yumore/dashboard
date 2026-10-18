import 'package:dio/dio.dart';
import 'package:dashboard/features/reading/book/repo/yck_item.dart';
import 'package:dashboard/features/reading/book/repo/yck_kind.dart';
import 'package:dashboard/features/reading/book/repo/yck_list_result.dart';

/// Kind of yckceo catalog entry.
class YckceoRepo {
  YckceoRepo({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              responseType: ResponseType.plain,
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
                    '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                'Accept': 'text/html,application/json,*/*',
              },
            ));

  static const String base = 'https://www.yckceo.com';

  static const String rssIndexUrl = '$base/yuedu/rss/index.html';
  static const String shuyuanIndexUrl = '$base/yuedu/shuyuan/index.html';
  static const String shuyuansIndexUrl = '$base/yuedu/shuyuans/index.html';

  final Dio _dio;

  /// 订阅源列表（Legado RSS）。
  Future<YckListResult> fetchRss({int page = 1, String keys = ''}) {
    return _fetchList(
      path: '/yuedu/rss/index.html',
      kind: YckKind.rss,
      page: page,
      keys: keys,
    );
  }

  /// 书源列表。
  Future<YckListResult> fetchSources({int page = 1, String keys = ''}) {
    return _fetchList(
      path: '/yuedu/shuyuan/index.html',
      kind: YckKind.source,
      page: page,
      keys: keys,
    );
  }

  /// 书源合集列表。
  Future<YckListResult> fetchCollections({int page = 1, String keys = ''}) {
    return _fetchList(
      path: '/yuedu/shuyuans/index.html',
      kind: YckKind.collection,
      page: page,
      keys: keys,
    );
  }

  /// @Deprecated Server only honors a single id in the path segment.
  ///
  /// Prefer per-id [YckItem.jsonUrl] and import concurrently.
  static String multiSourceJsonUrl(Iterable<String> ids) {
    final list = ids.where((e) => e.isNotEmpty).toList();
    if (list.isEmpty) {
      return '$base/yuedu/shuyuan/json/id/0.json';
    }
    return '$base/yuedu/shuyuan/json/id/${list.first}.json';
  }

  Future<YckListResult> _fetchList({
    required String path,
    required YckKind kind,
    required int page,
    required String keys,
  }) async {
    final res = await _dio.get<String>(
      '$base$path',
      queryParameters: {
        'page': page,
        if (keys.trim().isNotEmpty) 'keys': keys.trim(),
      },
    );
    final html = res.data ?? '';
    final List<YckItem> items;
    switch (kind) {
      case YckKind.collection:
        items = parseCollectionsHtml(html);
      case YckKind.rss:
        items = parseRssHtml(html);
      case YckKind.source:
        items = parseSourcesHtml(html);
    }
    final total = _parseTotal(html) ?? items.length;
    return YckListResult(items: items, total: total, page: page);
  }

  static int? _parseTotal(String html) {
    final m = RegExp(r'共有\s*(\d+)\s*条').firstMatch(html);
    if (m == null) return null;
    return int.tryParse(m.group(1) ?? '');
  }

  /// 书源卡片：checkbox id + 标题链接 + 更新时间 + 下载量。
  static List<YckItem> parseSourcesHtml(String html) {
    return _parseYlistCards(
      html,
      contentPath: '/yuedu/shuyuan/content/id/',
      kind: YckKind.source,
    );
  }

  /// 订阅源卡片：与书源同结构，路径为 `/yuedu/rss/content/id/`。
  static List<YckItem> parseRssHtml(String html) {
    return _parseYlistCards(
      html,
      contentPath: '/yuedu/rss/content/id/',
      kind: YckKind.rss,
    );
  }

  /// 通用 ylist 卡片解析（书源 / 订阅源共用 HTML 骨架）。
  static List<YckItem> _parseYlistCards(
    String html, {
    required String contentPath,
    required YckKind kind,
  }) {
    final out = <YckItem>[];
    final seen = <String>{};

    var chunks = RegExp(
      r'<div class="ylist"[\s\S]*?</div>\s*</div>',
      caseSensitive: false,
    ).allMatches(html).map((m) => m.group(0)!).toList();
    if (chunks.isEmpty) {
      chunks = RegExp(
        r'<div class="ylist"[\s\S]*?</div>',
        caseSensitive: false,
      ).allMatches(html).map((m) => m.group(0)!).toList();
    }

    final idRe =
        RegExp(r'name="ids\[\]"\s+value="(\d+)"', caseSensitive: false);
    final titleRe = RegExp(
      'href="${RegExp.escape(contentPath)}\\d+\\.html">([^<]+)</a>',
      caseSensitive: false,
    );
    final updatedRe = RegExp(
      r'<p class="m-right"[^>]*>([^<]*)</p>',
      caseSensitive: false,
    );
    final dlRe = RegExp(r'下载\s*[:：]\s*(\d+)');

    void addFromChunk(String chunk) {
      final id = idRe.firstMatch(chunk)?.group(1);
      final rawTitle = titleRe.firstMatch(chunk)?.group(1);
      if (id == null || rawTitle == null) return;
      if (!seen.add(id)) return;
      final titleDecoded = _decodeHtml(rawTitle).trim();
      if (titleDecoded.isEmpty) return;
      final split = _splitTitleHost(titleDecoded);
      final updated = updatedRe.firstMatch(chunk)?.group(1);
      final dl = dlRe.firstMatch(chunk)?.group(1);
      out.add(YckItem(
        id: id,
        title: split.$1,
        host: split.$2,
        updated: updated == null ? null : _decodeHtml(updated).trim(),
        downloads: dl == null ? null : int.tryParse(dl),
        kind: kind,
      ));
    }

    if (chunks.isNotEmpty) {
      for (final chunk in chunks) {
        addFromChunk(chunk);
      }
    } else {
      for (final m in idRe.allMatches(html)) {
        final rest = html.substring(m.end);
        final titleM = titleRe.firstMatch(rest);
        if (titleM == null) continue;
        addFromChunk('${m.group(0)}${rest.substring(0, titleM.end + 200)}');
      }
    }
    return out;
  }

  /// 合集卡片：标题链接 + 更新时间（无 checkbox / 下载量格式不一）。
  static List<YckItem> parseCollectionsHtml(String html) {
    final re = RegExp(
      r'<h2><a href="/yuedu/shuyuans/content/id/(\d+)\.html">([^<]+)</a>'
      r'[\s\S]*?'
      r'<p class="m-right"[^>]*>([^<]*)</p>',
      caseSensitive: false,
    );
    final out = <YckItem>[];
    final seen = <String>{};
    for (final m in re.allMatches(html)) {
      final id = m.group(1) ?? '';
      final title = _decodeHtml(m.group(2) ?? '').trim();
      if (id.isEmpty || title.isEmpty || !seen.add(id)) continue;
      out.add(YckItem(
        id: id,
        title: title,
        updated: _decodeHtml(m.group(3) ?? '').trim(),
        kind: YckKind.collection,
      ));
    }
    return out;
  }

  /// 标题里常带 `名称 https://host`。
  static (String, String?) _splitTitleHost(String raw) {
    final m =
        RegExp(r'^(.*?)(\s+https?://\S+|\s+\S+\.\S+)\s*$').firstMatch(raw);
    if (m != null) {
      final name = (m.group(1) ?? '').trim();
      final host = (m.group(2) ?? '').trim();
      if (name.isNotEmpty) return (name, host.isEmpty ? null : host);
    }
    return (raw, null);
  }

  static String _decodeHtml(String s) {
    return s
        .replaceAll('&middot;', '·')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}
