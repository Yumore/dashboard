/// Error returned by the bilibili web API envelope, or by a malformed response.
///
/// The source app checked `code == 0` inside each controller and showed
/// `message` verbatim; this exception carries both so the UI can do the same.
class BiliApiException implements Exception {
  const BiliApiException(this.code, this.message);

  /// `code` from the `{code, message, data}` envelope (`-1` when absent).
  final int code;
  final String message;

  @override
  String toString() => 'BiliApiException($code): $message';
}

/// The response body was not the expected `{code, message, data}` envelope.
class BiliApiFormatException extends BiliApiException {
  const BiliApiFormatException(super.code, super.message);

  @override
  String toString() => 'BiliApiFormatException($code): $message';
}
