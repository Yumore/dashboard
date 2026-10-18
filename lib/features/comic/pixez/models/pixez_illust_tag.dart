import '../pixez_json.dart';

/// A tag of an illust.
class PixezIllustTag {
  const PixezIllustTag({required this.name, this.translatedName});

  final String name;
  final String? translatedName;

  factory PixezIllustTag.fromJson(Map<String, dynamic> json) {
    return PixezIllustTag(
      name: pixezString(json['name']),
      translatedName: pixezStringOrNull(json['translated_name']),
    );
  }
}
