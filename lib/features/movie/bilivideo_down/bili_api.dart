import 'package:dashboard/features/movie/bilivideo_down/bili_api_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_play_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_info.dart';
import 'package:dio/dio.dart';

/// The two public bilibili endpoints this module talks to.
///
/// Ports `lib/constant/http_api.dart` and both `fetchVideoInfo` /
/// `collapse_widget.dart` call sites of the source app:
///
/// * `GET /x/web-interface/view?bvid=…`
/// * `GET /x/player/playurl?avid=…&cid=…&qn=80&platform=html5&otype=json&high_quality=1`
///
/// The source sent **no** headers at all. bilibili serves these endpoints from
/// `api.bilibili.com` and rejects requests without a bilibili `Referer` /
/// browser `User-Agent` from many networks, so [defaultHeaders] adds them; both
/// are public, non-credential headers. A `Cookie` header is **not** set by
/// default — member-only qualities need the caller's own cookie, which the user
/// supplies at runtime.
class BiliApi {
  BiliApi(this._dio);

  final Dio _dio;

  static const String apiHost = 'https://api.bilibili.com';
  static const String viewPath = '/x/web-interface/view';
  static const String playUrlPath = '/x/player/playurl';

  /// Makes [path] absolute; the injected [Dio] does not have to carry a
  /// `baseUrl` (`BiliApi` is used with a bare `dio` in tests and by the page).
  static String absoluteUrl(String path) =>
      path.startsWith('http') ? path : '$apiHost$path';

  /// Sent as `Referer`; bilibili's hotlink protection requires it.
  static const String defaultReferer = 'https://www.bilibili.com/';

  /// A desktop browser UA; the mobile/WebView UAs get a reduced quality list.
  static const String defaultUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  /// Headers attached to every request; [cookie] is the user's own bilibili
  /// cookie, when they supplied one for member-only content.
  static Map<String, String> defaultHeaders({String? cookie}) =>
      <String, String>{
        'Referer': defaultReferer,
        'User-Agent': defaultUserAgent,
        if (cookie != null && cookie.isNotEmpty) 'Cookie': cookie,
      };

  /// Query for `x/web-interface/view`; exactly one of [bvid]/[aid] is needed.
  static Map<String, dynamic> viewQuery({String? bvid, int? aid}) =>
      <String, dynamic>{
        if (bvid != null && bvid.isNotEmpty) 'bvid': bvid,
        if (aid != null && aid > 0) 'aid': aid,
      };

  /// Query for `x/player/playurl`, byte-for-byte the source app's parameters.
  ///
  /// [qn] is the requested quality, [fnval] selects DASH when the caller wants
  /// a muxed-tracks response (`fnval: 16` video + `fnval: 64` audio in the
  /// standard bilibili scheme; `0`/absent means the FLV `durl` answer the
  /// source relied on). The source never sent `fnval`/`fnver`.
  static Map<String, dynamic> playUrlQuery({
    required int avid,
    required int cid,
    int qn = biliDefaultQuality,
    int? fnval,
    int? fnver,
  }) => <String, dynamic>{
    'avid': avid,
    'cid': cid,
    'qn': qn,
    'platform': 'html5',
    'otype': 'json',
    'high_quality': 1,
    'fnval': ?fnval,
    'fnver': ?fnver,
  };

  /// `GET /x/web-interface/view`.
  Future<BiliVideoInfo> fetchVideoInfo({
    String? bvid,
    int? aid,
    String? cookie,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      absoluteUrl(viewPath),
      queryParameters: viewQuery(bvid: bvid, aid: aid),
      options: Options(headers: defaultHeaders(cookie: cookie)),
    );
    return BiliVideoInfo.fromJson(_dataOf(response));
  }

  /// `GET /x/player/playurl`.
  Future<BiliPlayInfo> fetchPlayInfo({
    required int avid,
    required int cid,
    int qn = biliDefaultQuality,
    int? fnval,
    int? fnver,
    String? cookie,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      absoluteUrl(playUrlPath),
      queryParameters: playUrlQuery(
        avid: avid,
        cid: cid,
        qn: qn,
        fnval: fnval,
        fnver: fnver,
      ),
      options: Options(headers: defaultHeaders(cookie: cookie)),
    );
    return BiliPlayInfo.fromJson(_dataOf(response));
  }

  /// Unwraps `{code, message, data}` and throws on any non-zero `code`.
  static Map<String, dynamic> _dataOf(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) {
      throw const BiliApiFormatException(-1, 'B站接口返回空响应');
    }
    final code = body['code'] is int
        ? body['code'] as int
        : int.tryParse('${body['code']}') ?? -1;
    if (code != 0) {
      throw BiliApiException(
        code,
        '${body['message'] ?? 'B站接口返回错误(code=$code)'}',
      );
    }
    final data = body['data'];
    if (data is! Map) {
      throw const BiliApiFormatException(-1, 'B站接口缺少 data 字段');
    }
    return Map<String, dynamic>.from(data);
  }
}
