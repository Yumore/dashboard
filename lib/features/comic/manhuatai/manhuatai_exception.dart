/// Transport/decoding failure of a manhuatai API call.
///
/// The source relied on Dio's `DioError` and its global interceptor toast;
/// this port surfaces a typed error that the screens render inline.
class ManhuataiApiException implements Exception {
  const ManhuataiApiException(this.message, {this.url = '', this.statusCode});

  final String message;
  final String url;
  final int? statusCode;

  @override
  String toString() {
    final buffer = StringBuffer('ManhuataiApiException: $message');
    if (url.isNotEmpty) {
      buffer.write(' ($url)');
    }
    if (statusCode != null) {
      buffer.write(' [HTTP $statusCode]');
    }
    return buffer.toString();
  }
}
