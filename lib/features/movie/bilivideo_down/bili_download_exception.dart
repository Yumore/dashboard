/// A download failed in a way that is not a cancellation.
///
/// The source app threw bare `Exception('Unhandled response status code: …')`
/// in this situation; this type keeps the status/URL for the UI and the tests.
class BiliDownloadException implements Exception {
  const BiliDownloadException(this.message, {this.statusCode, this.url});

  final String message;
  final int? statusCode;
  final String? url;

  @override
  String toString() =>
      'BiliDownloadException: $message'
      '${statusCode == null ? '' : ' (status $statusCode)'}';
}
