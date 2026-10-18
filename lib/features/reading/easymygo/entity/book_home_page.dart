/// Ported from `lib/plugin/component/api/manga/home/page/home_page.dart` and its
/// identical novel twin (merged, like [BookCover]).
class BookHomePage {
  const BookHomePage({
    required this.id,
    required this.label,
    this.hasCover = true,
    this.initKey = '',
    this.ext = '',
  });

  final String id;
  final String label;
  final bool hasCover;
  final String initKey;
  final String ext;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'has_cover': hasCover,
    'init_key': initKey,
    'ext': ext,
  };

  factory BookHomePage.fromJson(Map<String, Object?> json) => BookHomePage(
    id: '${json['id'] ?? ''}',
    label: '${json['label'] ?? ''}',
    hasCover: json['has_cover'] != false,
    initKey: '${json['init_key'] ?? ''}',
    ext: '${json['ext'] ?? ''}',
  );
}
