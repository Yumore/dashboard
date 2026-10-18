/// Ported from `NovelChapterLoadFrom` in `lib/entity/novel/novel_enum.dart`.
enum NovelChapterLoadFrom {
  /// The chapter points at a url: file or network.
  url,

  /// The chapter content is returned directly.
  direct;

  static NovelChapterLoadFrom fromName(String? name) {
    for (final value in NovelChapterLoadFrom.values) {
      if (value.name == name) {
        return value;
      }
    }
    return NovelChapterLoadFrom.direct;
  }
}

/// Ported from `NovelChapterLoadType`.
enum NovelChapterLoadType {
  epub,
  txt,
  pdf,
  html;

  static NovelChapterLoadType fromName(String? name) {
    for (final value in NovelChapterLoadType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return NovelChapterLoadType.html;
  }
}

/// Ported from `lib/entity/novel/novel_chapter/novel_chapter.dart`.
class NovelChapter {
  const NovelChapter({
    required this.label,
    required this.id,
    required this.src,
    this.loadFrom = NovelChapterLoadFrom.direct,
    this.loadType = NovelChapterLoadType.html,
    this.parameter = const <String, String>{},
  });

  final String label;
  final String id;

  /// Meaning depends on [loadFrom].
  final String src;

  final NovelChapterLoadFrom loadFrom;
  final NovelChapterLoadType loadType;
  final Map<String, String> parameter;

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'id': id,
    'src': src,
    'load_from': loadFrom.name,
    'load_type': loadType.name,
    'parameter': parameter,
  };

  factory NovelChapter.fromJson(Map<String, Object?> json) => NovelChapter(
    label: '${json['label'] ?? ''}',
    id: '${json['id'] ?? ''}',
    src: '${json['src'] ?? ''}',
    loadFrom: NovelChapterLoadFrom.fromName('${json['load_from'] ?? ''}'),
    loadType: NovelChapterLoadType.fromName('${json['load_type'] ?? ''}'),
    parameter: _stringMap(json['parameter']),
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
