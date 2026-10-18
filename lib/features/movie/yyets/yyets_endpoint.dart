/// 人人影视（YYeTs / Zmz）公开接口地址。
///
/// 三个主机全部来自源工程 `lib/app/Api.dart`（triage 已确认是公开接口，
/// 不含私有后端）：
///
/// * `a.zmzapi.com`     —— 主站 API（`linkUrl`，签名参数 `accesskey`/`client`）
/// * `file.apicvn.com`  —— 资源库文件列表 / 搜索（`latestResource`、`queryRRResource`）
/// * `m1.rrys2019.com`  —— 网页版资源页（`ResInfoPage._viewMoreDlLink`）
///
/// 源工程把签名常量硬编码在 `Api.linkUrl` 里，这里提出来放在一个类中，
/// 便于测试断言“请求 URL 与源完全一致”。
class YyetsEndpoint {
  const YyetsEndpoint._();

  /// `a.zmzapi.com`：所有 `Api.linkUrl(...)` 请求的基址。
  static const String baseUrl = 'http://a.zmzapi.com';

  /// `Api.linkUrl` 里的固定 accesskey。
  static const String accessKey = '519f9cab85c8059d17544947k361a827';

  /// `Api.linkUrl` 里的固定 client。
  static const String client = '2';

  /// `Api.linkUrl` 拼出来的公共前缀路径。
  static const String indexPath = '/index.php/';

  /// `file.apicvn.com`：资源库。
  static const String fileBaseUrl = 'http://file.apicvn.com';

  /// `Api.latestResource` —— `/file/list?page=$page`。
  static const String fileListPath = '/file/list';

  /// `Api.queryRRResource` —— `/file/search?keyword=$query&page=$page`。
  static const String fileSearchPath = '/file/search';

  /// `m1.rrys2019.com`：网页版资源条目页。
  static const String resourceBaseUrl = 'http://m1.rrys2019.com';

  /// `ResInfoPage._viewMoreDlLink` 拼出的地址。
  static String resourceItemUrl({
    required String rid,
    required Object? season,
    required Object? episode,
  }) =>
      '$resourceBaseUrl/resource/item?rid=$rid&season=$season&episode=$episode';

  /// `NewsPage.buildItem` 打开的资讯网页地址。
  static String articleUrl(Object? id) => 'http://m1.rryslink.com/article/$id';
}
