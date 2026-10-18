import '../pixez_json.dart';

/// A tag of a novel; includes the uploader flag pixiv returns.
class PixezNovelTag {
  const PixezNovelTag({
    required this.name,
    required this.translatedName,
    required this.addedByUploadedUser,
  });

  final String name;
  final String? translatedName;
  final bool addedByUploadedUser;

  factory PixezNovelTag.fromJson(Map<String, dynamic> json) {
    return PixezNovelTag(
      name: pixezString(json['name']),
      translatedName: pixezStringOrNull(json['translated_name']),
      addedByUploadedUser: pixezBool(json['added_by_uploaded_user']),
    );
  }
}
