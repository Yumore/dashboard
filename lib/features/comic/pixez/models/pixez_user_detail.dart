import '../pixez_json.dart';
import 'pixez_user.dart';
import 'pixez_user_profile.dart';
import 'pixez_user_publicity.dart';

/// `GET /v1/user/detail` response (`{user, profile, profile_publicity}`).
///
/// The source also parses `workspace`; the host UI does not show it, so it is
/// intentionally omitted (see the module report's "not ported" list).
class PixezUserDetail {
  const PixezUserDetail({
    required this.user,
    required this.profile,
    required this.profilePublicity,
  });

  final PixezUser user;
  final PixezUserProfile profile;
  final PixezUserPublicity profilePublicity;

  factory PixezUserDetail.fromJson(Map<String, dynamic> json) {
    return PixezUserDetail(
      user: PixezUser.fromJson(pixezMap(json['user'])),
      profile: PixezUserProfile.fromJson(pixezMap(json['profile'])),
      profilePublicity: PixezUserPublicity.fromJson(
        pixezMap(json['profile_publicity']),
      ),
    );
  }
}
