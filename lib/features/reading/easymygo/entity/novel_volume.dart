/// Ported from `NovelVolumeOrganizeType` in `lib/entity/novel/novel_enum.dart`.
enum NovelVolumeOrganizeType {
  /// The chapter list holds individual chapters (web version).
  multiChapter,

  /// The chapter list holds a single chapter (bunko / epub style).
  singleChapter;

  static NovelVolumeOrganizeType fromName(String? name) {
    for (final value in NovelVolumeOrganizeType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return NovelVolumeOrganizeType.multiChapter;
  }
}

/// Ported from `lib/entity/novel/novel_volume/novel_volume.dart`.
class NovelVolume {
  const NovelVolume({
    required this.label,
    required this.id,
    this.organizeType = NovelVolumeOrganizeType.multiChapter,
    this.parameter = const <String, String>{},
    this.ext = '',
  });

  final String label;
  final String id;
  final NovelVolumeOrganizeType organizeType;
  final Map<String, String> parameter;
  final String ext;

  Map<String, Object?> toJson() => <String, Object?>{
    'label': label,
    'id': id,
    'organize_type': organizeType.name,
    'parameter': parameter,
    'ext': ext,
  };

  factory NovelVolume.fromJson(Map<String, Object?> json) => NovelVolume(
    label: '${json['label'] ?? ''}',
    id: '${json['id'] ?? ''}',
    organizeType: NovelVolumeOrganizeType.fromName('${json['organize_type'] ?? ''}'),
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
