/// A douban request (or mock-fixture) failure that is safe to show and retry.
///
/// Mirrors `MovieAppException` so both movie sources fail the same way.
class FlutterDouBanException implements Exception {
  const FlutterDouBanException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
