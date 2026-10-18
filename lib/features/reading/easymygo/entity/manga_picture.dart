/// Ported from `PictureLoadType` in `lib/entity/manga/manga_enum.dart`.
enum PictureLoadType {
  /// Load [MangaPicture.url] directly (network or local).
  normal;

  static PictureLoadType fromName(String? name) {
    for (final value in PictureLoadType.values) {
      if (value.name == name) {
        return value;
      }
    }
    return PictureLoadType.normal;
  }
}

/// Ported from `lib/entity/manga/manga_picture/manga_picture.dart`.
class MangaPicture {
  const MangaPicture({
    this.url = '',
    this.type = PictureLoadType.normal,
    this.parameter = const <String, String>{},
  });

  final String url;
  final PictureLoadType type;
  final Map<String, String> parameter;

  Map<String, Object?> toJson() => <String, Object?>{
    'url': url,
    'type': type.name,
    'parameter': parameter,
  };

  factory MangaPicture.fromJson(Map<String, Object?> json) => MangaPicture(
    url: '${json['url'] ?? ''}',
    type: PictureLoadType.fromName('${json['type'] ?? ''}'),
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
