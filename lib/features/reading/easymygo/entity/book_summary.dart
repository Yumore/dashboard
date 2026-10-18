/// Ported from `lib/entity/manga/manga_summary/manga_summary.dart` and the novel
/// twin. The two shapes were identical, so the port keeps one class.
class BookSummary {
  const BookSummary({required this.source, required this.id, this.ext = ''});

  final String source;
  final String id;
  final String ext;

  /// Ported from `MangaDetailedExt.identify` / `MangaCoverExt.identify`.
  String get identify => '$id-|-$source';

  Map<String, Object?> toJson() => <String, Object?>{
    'source': source,
    'id': id,
    'ext': ext,
  };

  factory BookSummary.fromJson(Map<String, Object?> json) => BookSummary(
    source: '${json['source'] ?? ''}',
    id: '${json['id'] ?? ''}',
    ext: '${json['ext'] ?? ''}',
  );
}
