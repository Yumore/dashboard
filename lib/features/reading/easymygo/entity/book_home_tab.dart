/// Ported from `lib/entity/book/home_tab/book_home_tab.dart` — first level tab.
class BookHomeTab {
  const BookHomeTab({
    required this.id,
    required this.label,
    required this.hasSecondTab,
    this.ext = '',
  });

  final String id;
  final String label;
  final bool hasSecondTab;
  final String ext;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'label': label,
    'has_second_tab': hasSecondTab,
    'ext': ext,
  };

  factory BookHomeTab.fromJson(Map<String, Object?> json) => BookHomeTab(
    id: '${json['id'] ?? ''}',
    label: '${json['label'] ?? ''}',
    hasSecondTab: json['has_second_tab'] == true,
    ext: '${json['ext'] ?? ''}',
  );
}
