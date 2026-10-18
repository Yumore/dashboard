import '../pixez_json.dart';

/// `profile_image_urls` of a pixiv user.
class PixezProfileImageUrls {
  const PixezProfileImageUrls({required this.medium});

  final String medium;

  factory PixezProfileImageUrls.fromJson(Map<String, dynamic> json) {
    return PixezProfileImageUrls(medium: pixezString(json['medium']));
  }
}
