/// 电影天堂接口或响应解析失败。
///
/// 源工程在非 200 时返回 `null`，调用方再触发空指针；宿主改为抛出带
/// 状态码的异常，页面才能给出可重试的错误态。
class DyttApiException implements Exception {
  const DyttApiException(this.message, {this.statusCode});

  final String message;

  /// 服务端状态码；本地解析失败时为 `null`。
  final int? statusCode;

  @override
  String toString() => message;
}
