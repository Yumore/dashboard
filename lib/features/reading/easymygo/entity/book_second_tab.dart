/// Ported from `BookSecondTab` in `lib/entity/book/home_tab/book_home_tab.dart`.
class BookSecondTab {
  const BookSecondTab({required this.id, required this.label, this.ext = ''});

  final String id;
  final String label;
  final String ext;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'ext': ext,
  };

  factory BookSecondTab.fromJson(Map<String, Object?> json) => BookSecondTab(
    id: '${json['id'] ?? ''}',
    label: '${json['label'] ?? ''}',
    ext: '${json['ext'] ?? ''}',
  );
}
