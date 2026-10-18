/// Raised when YouTube returns an unplayable response or a request fails.
class YoutubeDlStreamException implements Exception {
  const YoutubeDlStreamException(this.message);

  final String message;

  @override
  String toString() => 'YoutubeDlStreamException: $message';
}
