/// 人人影视请求失败。
///
/// 源工程在各处 `throw Exception(res.data["info"])`（`Api.getResInfo`、
/// `Api.commentUser`、`Api.rating` …），直接 `toString()` 出来的文案会带
/// `Exception: ` 前缀。这里保留源工程的用户可见文案，去掉前缀噪音，并额外
/// 记录 HTTP 状态码，方便调用方区分“业务失败”和“网络失败”。
class YyetsException implements Exception {
  const YyetsException(this.message, {this.statusCode});

  /// 可直接展示给用户的文案（源工程的 `info` 字段或网络层兜底文案）。
  final String message;

  /// HTTP 状态码；网络层失败时为 null。
  final int? statusCode;

  @override
  String toString() => message;
}
