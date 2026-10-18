import '../pixez_json.dart';
import 'pixez_profile_image_urls.dart';

/// A pixiv user as embedded in illust/novel/user-preview responses.
class PixezUser {
  const PixezUser({
    required this.id,
    required this.name,
    required this.account,
    required this.profileImageUrls,
    this.comment,
    this.isFollowed,
  });

  final int id;
  final String name;
  final String account;
  final PixezProfileImageUrls profileImageUrls;
  final String? comment;
  final bool? isFollowed;

  String get avatarUrl => profileImageUrls.medium;

  factory PixezUser.fromJson(Map<String, dynamic> json) {
    return PixezUser(
      id: pixezInt(json['id']),
      name: pixezString(json['name']),
      account: pixezString(json['account']),
      profileImageUrls: PixezProfileImageUrls.fromJson(
        pixezMap(json['profile_image_urls']),
      ),
      comment: pixezStringOrNull(json['comment']),
      isFollowed: json['is_followed'] == null
          ? null
          : pixezBool(json['is_followed']),
    );
  }
}
