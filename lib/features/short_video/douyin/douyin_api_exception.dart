/// 抖音接口/解析失败。
class DouyinApiException implements Exception {
  const DouyinApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
