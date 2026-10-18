/// 今日看片（appapi.php CMS）接口异常。
class FlutterMoviesException implements Exception {
  const FlutterMoviesException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
