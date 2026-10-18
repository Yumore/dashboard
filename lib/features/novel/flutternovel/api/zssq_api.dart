import 'dart:convert';

import 'package:dashboard/features/novel/flutternovel/api/api_result.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_recommend.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_review.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_source.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_detail_info.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_key_word_search.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_short_comment.dart';
import 'package:http/http.dart' as http;

/// The zhuishushenqi client — the full surface of the source's `NovelApi`
/// (flutter_novel/lib/app/api/api_novel.dart), ported onto the host's
/// `AlexandriaSource` shape: an injectable [http.Client], pure static query
/// builders and pure static parsers (so the real paths/params and every JSON
/// mapping are testable without a network), and instance `get*` methods that
/// perform the HTTP call.
///
/// Every source method wrapped its call in try/catch, printed the exception and
/// returned the default (failed) response; the port keeps that contract and
/// returns [ApiResult.failure] instead of printing.
class ZssqApi {
  ZssqApi({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? requestTimeout;

  final http.Client _client;
  final Duration _timeout;

  static const String baseUrl = 'http://api.zhuishushenqi.com/';
  static const String readerImageUrl = 'http://statics.zhuishushenqi.com';

  /// The source spelling: `QUERY_AUTO_COMPLETE_QUERY_KEYWORD`.
  static const String autoCompletePath = 'book/auto-complete?query=';
  static const String hotWordPath = 'book/hot-word';
  static const String fuzzySearchPath = 'book/fuzzy-search';
  static const String bookPath = 'book/';
  static const String shortReviewPath = 'post/short-review';
  static const String reviewByBookPath = 'post/review/by-book';
  static const String recommendPath = 'recommend';
  static const String atocPath = 'atoc/';
  static const String btocPath = 'btoc';
  static const String chapterUpBaseUrl =
      'http://chapterup.zhuishushenqi.com/chapter/';

  static const Duration requestTimeout = Duration(seconds: 20);

  /// `book/{id}/recommend` — the source template was `book/{id}/recommend`.
  static const String bookRecommendTemplate = 'book/{id}/recommend';

  /// `atoc/{sourceid}?view=chapters`
  static const String atocTemplate = 'atoc/{sourceid}?view=chapters';

  /// `btoc?book={bookId}&view=summary`
  static const String btocTemplate = 'btoc?book={bookId}&view=summary';

  // ---------------------------------------------------------------------------
  // Query building (pure)
  // ---------------------------------------------------------------------------

  static String autoCompleteUrl(String keyword) =>
      baseUrl + autoCompletePath + keyword;

  static String hotWordUrl() => baseUrl + hotWordPath;

  static Uri fuzzySearchUri(String query, {int start = 0, int limit = 20}) =>
      Uri.parse(baseUrl + fuzzySearchPath).replace(
        queryParameters: <String, String>{
          'query': query,
          'start': '$start',
          'limit': '$limit',
        },
      );

  static String bookDetailUrl(String bookId) => baseUrl + bookPath + bookId;

  static Uri shortReviewUri(
    String id, {
    String sort = 'updated',
    int start = 0,
    int limit = 2,
  }) => Uri.parse(baseUrl + shortReviewPath).replace(
    queryParameters: <String, String>{
      'book': id,
      'sort': sort,
      'start': '$start',
      'limit': '$limit',
    },
  );

  static Uri reviewByBookUri(
    String id, {
    String sort = 'updated',
    int start = 0,
    int limit = 2,
  }) => Uri.parse(baseUrl + reviewByBookPath).replace(
    queryParameters: <String, String>{
      'book': id,
      'sort': sort,
      'start': '$start',
      'limit': '$limit',
    },
  );

  static String bookRecommendUrl(String id) =>
      baseUrl + bookRecommendTemplate.replaceAll('{id}', id);

  static String atocUrl(String sourceId) =>
      baseUrl + atocTemplate.replaceAll('{sourceid}', sourceId);

  static Uri btocUri(String bookId) =>
      Uri.parse(baseUrl + btocPath).replace(
        queryParameters: <String, String>{'book': bookId, 'view': 'summary'},
      );

  static String chapterContentUrl(String link) => chapterUpBaseUrl + link;

  // ---------------------------------------------------------------------------
  // Parsing (pure, raw body in -> model out)
  // ---------------------------------------------------------------------------

  static List<String> parseSearchWord(String body) {
    final decoded = _decodeMap(body);
    return _stringList(decoded?['keywords']);
  }

  static List<String> parseHotWords(String body) {
    final decoded = _decodeMap(body);
    return _stringList(decoded?['hotWords']);
  }

  static NovelKeyWordSearch parseKeyWordSearch(String body) =>
      NovelKeyWordSearch.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  static NovelDetailInfo parseDetail(String body) =>
      NovelDetailInfo.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  static NovelShortComment parseShortReview(String body) =>
      NovelShortComment.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  static NovelBookReview parseReview(String body) =>
      NovelBookReview.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  static NovelBookRecommend parseRecommend(String body) =>
      NovelBookRecommend.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  static List<NovelBookSource> parseSourceList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return const <NovelBookSource>[];
    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map((element) => NovelBookSource.fromJson(element.cast<String, dynamic>()))
        .toList();
  }

  static NovelBookChapter parseCatalog(String body) => NovelBookChapter.fromJson(
    _decodeMap(body) ?? <String, dynamic>{},
  ).withBookIdOnChapters();

  static NovelChapterContent parseChapterContent(String body) =>
      NovelChapterContent.fromJson(_decodeMap(body) ?? <String, dynamic>{});

  // ---------------------------------------------------------------------------
  // Network
  // ---------------------------------------------------------------------------

  Future<ApiResult<List<String>>> getSearchWord(String keyword) async {
    try {
      final body = await _get(Uri.parse(autoCompleteUrl(keyword)));
      return ApiResult<List<String>>.success(parseSearchWord(body));
    } catch (_) {
      return ApiResult<List<String>>.failure();
    }
  }

  Future<ApiResult<List<String>>> getHotSearchWord() async {
    try {
      final body = await _get(Uri.parse(hotWordUrl()));
      return ApiResult<List<String>>.success(parseHotWords(body));
    } catch (_) {
      return ApiResult<List<String>>.failure();
    }
  }

  Future<ApiResult<NovelKeyWordSearch>> searchTargetKeyWord(
    String keyword, {
    int start = 0,
    int limit = 20,
  }) async {
    try {
      final body = await _get(
        fuzzySearchUri(keyword, start: start, limit: limit),
      );
      return ApiResult<NovelKeyWordSearch>.success(parseKeyWordSearch(body));
    } catch (_) {
      return ApiResult<NovelKeyWordSearch>.failure();
    }
  }

  Future<ApiResult<NovelDetailInfo>> getNovelDetailInfo(String bookId) async {
    try {
      final body = await _get(Uri.parse(bookDetailUrl(bookId)));
      return ApiResult<NovelDetailInfo>.success(parseDetail(body));
    } catch (_) {
      return ApiResult<NovelDetailInfo>.failure();
    }
  }

  Future<ApiResult<NovelShortComment>> getNovelShortReview(
    String id, {
    String sort = 'updated',
    int start = 0,
    int limit = 2,
  }) async {
    try {
      final body = await _get(
        shortReviewUri(id, sort: sort, start: start, limit: limit),
      );
      return ApiResult<NovelShortComment>.success(parseShortReview(body));
    } catch (_) {
      return ApiResult<NovelShortComment>.failure();
    }
  }

  Future<ApiResult<NovelBookReview>> getNovelBookReview(
    String id, {
    String sort = 'updated',
    int start = 0,
    int limit = 2,
  }) async {
    try {
      final body = await _get(
        reviewByBookUri(id, sort: sort, start: start, limit: limit),
      );
      return ApiResult<NovelBookReview>.success(parseReview(body));
    } catch (_) {
      return ApiResult<NovelBookReview>.failure();
    }
  }

  Future<ApiResult<NovelBookRecommend>> getNovelBookRecommend(
    String id,
  ) async {
    try {
      final body = await _get(Uri.parse(bookRecommendUrl(id)));
      return ApiResult<NovelBookRecommend>.success(parseRecommend(body));
    } catch (_) {
      return ApiResult<NovelBookRecommend>.failure();
    }
  }

  Future<ApiResult<List<NovelBookSource>>> getNovelSource(
    String novelId,
  ) async {
    try {
      final body = await _get(btocUri(novelId));
      return ApiResult<List<NovelBookSource>>.success(parseSourceList(body));
    } catch (_) {
      return ApiResult<List<NovelBookSource>>.failure();
    }
  }

  Future<ApiResult<NovelBookChapter>> getNovelCatalog(String sourceId) async {
    try {
      final body = await _get(Uri.parse(atocUrl(sourceId)));
      return ApiResult<NovelBookChapter>.success(parseCatalog(body));
    } catch (_) {
      return ApiResult<NovelBookChapter>.failure();
    }
  }

  /// The chapterup body. The source never modelled it — it read
  /// `json.decode(body)["chapter"]["cpContent"]` directly in the reader view
  /// model — so the payload is handed back as [NovelChapterContent] and the
  /// caller still strips the inline HTML exactly as the source did.
  Future<ApiResult<NovelChapterContent>> getChapterContent(String link) async {
    try {
      final body = await _get(Uri.parse(chapterContentUrl(link)));
      return ApiResult<NovelChapterContent>.success(parseChapterContent(body));
    } catch (_) {
      return ApiResult<NovelChapterContent>.failure();
    }
  }

  void close() => _client.close();

  Future<String> _get(Uri uri) async {
    final response = await _client
        .get(uri, headers: const <String, String>{'Accept': 'application/json'})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} for $uri');
    }
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }

  static Map<String, dynamic>? _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map) return decoded.cast<String, dynamic>();
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .where((element) => element != null)
        .map((element) => '$element')
        .toList();
  }
}
