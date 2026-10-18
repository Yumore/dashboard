/// A single z-library search hit, ported from the source `LittlebookInfo`.
///
/// The source field `leanguage` (sic) is spelled [language] here; the meaning is
/// unchanged. [bookId] keeps the raw `href` of the result link (for example
/// `/book/1001/alpha`), exactly as the source stored it, because the source
/// composed the site URL as `siteRoot + bookID`.
class ZlibBook {
  const ZlibBook({
    required this.title,
    required this.imageUrl,
    required this.authors,
    required this.authorUrls,
    required this.publisher,
    required this.publisherUrl,
    required this.year,
    required this.language,
    required this.file,
    required this.bookId,
  });

  final String title;
  final String imageUrl;
  final List<String> authors;
  final List<String> authorUrls;
  final String publisher;
  final String publisherUrl;
  final String year;
  final String language;
  final String file;
  final String bookId;

  /// The source hid the publisher row when it was the `not given` placeholder.
  bool get hasPublisher => publisher != 'not given';
}
