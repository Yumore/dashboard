/// A TMDb request failure that is safe to show to the user and worth retrying.
class MovieAppException implements Exception {
  const MovieAppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
