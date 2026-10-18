/// Ported from `ChapterShowType` in `lib/entity/manga/manga_enum.dart`.
enum ChapterShowType {
  /// A normal chapter made of several pictures.
  normal,

  /// A single very large picture; the reader has to adapt.
  singlePicture;

  static ChapterShowType fromName(String? name) {
    for (final value in ChapterShowType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return ChapterShowType.normal;
  }
}

/// Ported from `lib/entity/manga/manga_chapter/manga_chapter.dart`.
class MangaChapter {
  const MangaChapter({
    required this.label,
    required this.id,
    this.showType = ChapterShowType.normal,
    this.parameter = const <String, String>{},
    this.ext = '',
  });

  final String label;
  final String id;
  final ChapterShowType showType;

  /// Passed through to the reader.
  final Map<String, String> parameter;

  /// Owned by the source; used to carry extra data through.
  final String ext;

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'id': id,
    'show_type': showType.name,
    'parameter': parameter,
    'ext': ext,
  };

  factory MangaChapter.fromJson(Map<String, Object?> json) => MangaChapter(
    label: '${json['label'] ?? ''}',
    id: '${json['id'] ?? ''}',
    showType: ChapterShowType.fromName('${json['show_type'] ?? ''}'),
    parameter: _stringMap(json['parameter']),
    ext: '${json['ext'] ?? ''}',
  );
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) {
    return const <String, String>{};
  }
  return <String, String>{
    for (final entry in value.entries) '${entry.key}': '${entry.value}',
  };
}
