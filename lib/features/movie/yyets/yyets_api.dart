import 'package:dashboard/features/movie/yyets/yyets_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_endpoint.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_file_entry.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_rank_result.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_session.dart';
import 'package:dio/dio.dart';

/// 人人影视 HTTP 客户端。
///
/// 一一对应源工程 `lib/app/Api.dart` 里的静态方法，但把 Dio 做成可注入的：
/// 源工程用 `static Dio _dioClient` + `MyApp.rrUser` 全局单例，测试里没法替换
/// 传输层；移植版由构造函数注入 `Dio` 与 [YyetsSession]。
///
/// 请求签名与参数拼装（`Api.linkUrl`）完全照抄：
///
/// ```
/// {base}/index.php/?accesskey=519f9cab85c8059d17544947k361a827&client=2&{query}
/// ```
///
/// 注意源工程是 `?accesskey=...&client=2&` **紧跟**业务参数，业务参数自己带
/// `m=`/`a=`/`g=` 且顺序原样保留（例如搜索是 `st`、`a`、`g`、`limit`、`k`、
/// `page`、`m`）。这些顺序对服务端无意义，但对“移植是否忠实”有意义。
class YyetsApi {
  YyetsApi({Dio? dio, YyetsSession session = YyetsSession.anonymous})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
      _session = session;

  final Dio _dio;
  final YyetsSession _session;

  // ---------------------------------------------------------------------------
  // URL 构造（对应源工程 `Api.rankUrl` / `detailUrl` / ... 这些 static getter）
  // ---------------------------------------------------------------------------

  /// 源 `Api.linkUrl`：`a.zmzapi.com` + 固定签名 + 业务查询串。
  static String linkUrl(
    String query, {
    String baseUrl = YyetsEndpoint.baseUrl,
  }) =>
      '$baseUrl${YyetsEndpoint.indexPath}'
      '?accesskey=${YyetsEndpoint.accessKey}'
      '&client=${YyetsEndpoint.client}'
      '&$query';

  /// 源 `Api.rankUrl`。
  static String get rankUrl => linkUrl('m=index&a=HOT&limit=100&g=api/v3');

  /// 源 `Api.detailUrl`。
  static String detailUrl(String id) =>
      linkUrl('m=index&a=resource&rid=$id&g=api/v2');

  /// 源 `Api.commentUrl`。
  static String commentUrl(String id, String channel, int page) => linkUrl(
    'a=fetch&itemid=$id&channel=$channel&pagesize=20&page=$page&m=comment',
  );

  /// 源 `Api.resUrl`。
  ///
  /// 源工程签名里带了 `channel` 参数却没有真的拼进去（`channel` 形参只用于
  /// 判断分支），移植版保留同样的参数列表，实际 URL 与源逐字节一致。
  static String resUrl({
    required String id,
    String itemid = '',
    String channel = '',
    String season = '',
    String episode = '',
  }) => linkUrl(
    'g=api/v2&m=index&a=resource_item&id=$id&season=$season'
    '&episode=$episode&itemid=$itemid',
  );

  /// 源 `Api.search` 的查询串。
  static String searchUrl(String query, int page) => linkUrl(
    'st=resource&a=search&g=api%2Fv2&limit=10&k=$query&page=$page&m=index',
  );

  /// 源 `Api.latestResource` / `Api.queryRRResource` 用的资源库地址。
  static String fileListUrl(int page) =>
      '${YyetsEndpoint.fileBaseUrl}${YyetsEndpoint.fileListPath}?page=$page';

  static String fileSearchUrl(String keyword, int page) =>
      '${YyetsEndpoint.fileBaseUrl}${YyetsEndpoint.fileSearchPath}'
      '?keyword=$keyword&page=$page';

  /// 源 `Api.myFavorites`。
  static String favoritesUrl(int page, {int limit = 20}) => linkUrl(
    'g=api/v2&m=index&a=fav_list&ft=resource&page=$page&limit=$limit',
  );

  /// 源 `Api.news`。
  static String newsUrl(int page) =>
      linkUrl('g=api/v2&m=index&a=new_article_list&page=$page');

  // ---------------------------------------------------------------------------
  // 业务接口
  // ---------------------------------------------------------------------------

  /// 源 `Api.loadRank()` —— 首页 6 个榜单一次返回。
  Future<YyetsRankResult> loadRank() async {
    final data = await _getData(rankUrl);
    return YyetsRankResult.fromJson(YyetsJson.asMap(data));
  }

  /// 源 `Api.search(query, page)` —— 每页 10 条。
  ///
  /// 源工程用“返回空列表”表示没有下一页，页码从 1 开始由调用方自增。
  Future<List<YyetsMovie>> search(String query, int page) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw const YyetsException('搜索关键字不能为空');
    }
    final envelope = YyetsJson.asMap(await _get(searchUrl(trimmed, page)));
    final data = YyetsJson.asMap(envelope['data']);
    return YyetsJson.asMapList(data['list'])
        .map(YyetsMovie.fromJson)
        .where((movie) => movie.hasId)
        .toList(growable: false);
  }

  /// 源 `Api.getDetail(id)`。
  Future<YyetsDetail> getDetail(String id) async {
    final data = await _getData(detailUrl(id));
    return YyetsDetail.fromJson(YyetsJson.asMap(data));
  }

  /// 源 `Api.getResInfo(...)` —— 资源详情页：格式与下载链接。
  ///
  /// 源工程在 `status != 1` 时 `throw Exception(res.data["info"])`，
  /// 这里抛 [YyetsException]，并允许页面直接用 `info` 文案提示用户。
  Future<YyetsResourceDetail> getResourceDetail({
    required String id,
    String itemid = '',
    String channel = '',
    String season = '',
    String episode = '',
  }) async {
    final envelope = YyetsJson.asMap(
      await _get(
        resUrl(
          id: id,
          itemid: itemid,
          channel: channel,
          season: season,
          episode: episode,
        ),
      ),
    );
    if (YyetsJson.asInt(envelope['status']) != 1) {
      throw YyetsException(
        YyetsJson.asNullableString(envelope['info']) ?? '资源加载失败，请重试',
      );
    }
    return YyetsResourceDetail.fromJson(YyetsJson.asMap(envelope['data']));
  }

  /// 源 `Api.loadComments(id, channel, page)` —— 每页 20 条。
  Future<List<Map<String, dynamic>>> loadComments(
    String id,
    String channel,
    int page,
  ) async {
    final data = await _getData(commentUrl(id, channel, page));
    return YyetsJson.asMapList(YyetsJson.asMap(data)['list']);
  }

  /// 源 `Api.myFavorites(page, limit:)`。
  Future<List<YyetsMovie>> myFavorites(int page, {int limit = 20}) async {
    final data = await _getData(favoritesUrl(page, limit: limit));
    return YyetsJson.asMapList(data)
        .map((item) => YyetsJson.asMap(item['detail']))
        .where((detail) => detail.isNotEmpty)
        .map(YyetsMovie.fromJson)
        .toList(growable: false);
  }

  /// 源 `Api.news(page)`。
  Future<List<YyetsNewsItem>> news(int page) async {
    final data = await _getData(newsUrl(page));
    return YyetsJson.asMapList(
      data,
    ).map(YyetsNewsItem.fromJson).toList(growable: false);
  }

  /// 源 `Api.latestResource(page)` —— `file.apicvn.com` 的响应**没有信封**，
  /// 直接就是列表。
  Future<List<YyetsFileEntry>> latestResources(int page) async {
    final data = await _get(fileListUrl(page));
    return YyetsJson.asMapList(
      data,
    ).map(YyetsFileEntry.fromJson).toList(growable: false);
  }

  /// 源 `Api.queryRRResource(query, page)`。
  Future<List<YyetsFileEntry>> searchResources(String keyword, int page) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      throw const YyetsException('搜索关键字不能为空');
    }
    final data = await _get(fileSearchUrl(trimmed, page));
    return YyetsJson.asMapList(
      data,
    ).map(YyetsFileEntry.fromJson).toList(growable: false);
  }

  /// 释放传输层。可以安全地重复调用。
  void dispose() => _dio.close(force: true);

  // ---------------------------------------------------------------------------
  // 传输层
  // ---------------------------------------------------------------------------

  /// 发一次 GET。
  ///
  /// 源工程 `Api.wrapUrl` 会把 `file.apicvn.com` 的请求换成另一个 host；
  /// 移植版直接传绝对 URL（[fileListUrl] / [fileSearchUrl]）达到同样效果。
  /// 已登录会话按源工程拦截器的行为追加 `uid` / `token`。
  Future<Object?> _get(String path) async {
    final query = _session.authQuery;
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        path,
        queryParameters: query.isEmpty ? null : query,
      );
    } on DioException catch (error) {
      throw YyetsException(
        _messageFor(error),
        statusCode: error.response?.statusCode,
      );
    }
    final status = response.statusCode;
    if (status != null && (status < 200 || status >= 300)) {
      throw YyetsException('请求失败：HTTP $status', statusCode: status);
    }
    return response.data;
  }

  /// 取信封里的 `data`；`status != 1` 时用 `info` 抛错。
  ///
  /// 源工程的 `loadRank` / `getDetail` / `news` 都没检查 `status`，只在
  /// `getResInfo` / `rating` / `commentUser` 里检查。移植版统一检查——源工程
  /// 不检查的那几处，失败时会静默返回 null 然后在 widget 里崩溃。
  Future<Object?> _getData(String path) async {
    final data = await _get(path);
    if (data is Map) {
      final map = YyetsJson.asMap(data);
      final status = map['status'];
      if (status != null && YyetsJson.asInt(status) != 1) {
        throw YyetsException(
          YyetsJson.asNullableString(map['info']) ?? '请求失败，请重试',
        );
      }
      return map['data'];
    }
    return data;
  }

  static String _messageFor(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) return '请求失败：HTTP $status';
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => '请求超时，请重试',
      DioExceptionType.badCertificate => '服务器证书校验失败',
      DioExceptionType.cancel => '请求已取消',
      DioExceptionType.connectionError => '网络连接失败，请检查网络',
      DioExceptionType.badResponse => '服务器返回异常',
      DioExceptionType.unknown => '网络请求失败，请重试',
    };
  }
}
