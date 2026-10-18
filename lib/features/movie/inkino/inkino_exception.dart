/// A Finnkino request failure that is safe to show to the user and worth
/// retrying. Mirrors the host's `MovieAppException` shape.
class InKinoException implements Exception {
  const InKinoException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
