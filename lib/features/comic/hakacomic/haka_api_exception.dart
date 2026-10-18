/// Error raised for any non-200 picacomic response.
///
/// Upstream threw raw strings (`haka_comic/lib/network/client.dart:121,126`);
/// this port keeps the message text but wraps it in a typed exception.
class HakaApiException implements Exception {
  const HakaApiException(this.message, {this.statusCode});

  final String message;

  final int? statusCode;

  /// True for `401` responses, which invalidate the stored token upstream.
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() {
    if (statusCode == null) return 'HakaApiException: $message';
    return 'HakaApiException($statusCode): $message';
  }
}
