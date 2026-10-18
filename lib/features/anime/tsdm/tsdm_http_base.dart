import 'dart:typed_data';

/// A http response as returned by [TsdmHttpClient].
///
/// The source project used `dio.Response`; the port carries only the fields the
/// repositories actually read: status code, decoded body, effective url,
/// response headers and the raw body bytes.
class TsdmHttpResponse {
  const TsdmHttpResponse({
    required this.statusCode,
    required this.data,
    required this.realUri,
    required this.headers,
    required this.bodyBytes,
  });

  /// Response status code.
  final int statusCode;

  /// Decoded body text.
  final String data;

  /// Effective url after redirects.
  final Uri realUri;

  /// Response headers, lower cased names.
  final Map<String, String> headers;

  /// Raw body bytes.
  final Uint8List bodyBytes;
}
