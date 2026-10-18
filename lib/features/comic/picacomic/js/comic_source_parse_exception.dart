/// Ports PicaComic's `ComicSourceParseException`.
class ComicSourceParseException implements Exception {
  final String message;

  ComicSourceParseException(this.message);

  @override
  String toString() => message;
}
