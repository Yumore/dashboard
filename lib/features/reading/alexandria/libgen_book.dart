/// A single Library Genesis search hit, ported from `LibGenBookInfo`.
///
/// All thirteen source fields are kept. [isbn] and [extension] are spelled out
/// (the source used `ISBN` and `extention`). [id] was declared by the source but
/// never populated, so it stays empty until some upstream markup provides it.
class LibGenBook {
  const LibGenBook({
    required this.title,
    required this.bookUrl,
    required this.imageUrl,
    required this.authors,
    required this.series,
    required this.publisher,
    required this.year,
    required this.language,
    required this.isbn,
    required this.size,
    required this.pages,
    required this.extension,
    this.id = '',
  });

  final String title;
  final String bookUrl;
  final String imageUrl;
  final List<String> authors;
  final String series;
  final String publisher;
  final String year;
  final String language;
  final String isbn;
  final String size;
  final String pages;
  final String extension;
  final String id;

  /// The source hid the publisher row when it was the `not given` placeholder.
  bool get hasPublisher => publisher != 'not given';
}
