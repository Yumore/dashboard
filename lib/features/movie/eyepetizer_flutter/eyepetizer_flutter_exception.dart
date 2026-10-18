/// Transport failure raised by [EyepetizerFlutterHttp].
///
/// The source let `DioException`s escape to the call sites, which then never
/// checked them; every ported screen would have thrown into an empty
/// `StreamBuilder`. The port wraps the same information in one typed exception
/// so a screen can render it.
class EyepetizerFlutterException implements Exception {
  const EyepetizerFlutterException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}
