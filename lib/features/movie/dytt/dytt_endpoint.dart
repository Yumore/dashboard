/// 电影天堂（DYTT）公开接口的端点常量。
///
/// 源工程 `lib/networkapi.dart` 把 `http://m.dydytt.net:8080` 写死在两个
/// `http.post` 调用里；这里集中成常量，测试可以逐字符比对，页面与 API
/// 也不需要各写一遍域名。
class DyttEndpoint {
  DyttEndpoint._();

  /// 源站没有 HTTPS，公开接口固定走 8080 端口的明文 HTTP。
  static const String origin = 'http://m.dydytt.net:8080';

  static const String movieListPath = '/adminapi/api/movieList.json';

  static const String movieDetailPath = '/adminapi/api/movieDetail.json';

  static const String movieListUrl = '$origin$movieListPath';

  static const String movieDetailUrl = '$origin$movieDetailPath';
}
