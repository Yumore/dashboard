import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/owner.dart`.
///
/// `city` keeps the source's `json['city'] == null ? "" : ...` fallback: the
/// picture-detail footer printed it unconditionally.
class EyepetizerFlutterOwner {
  const EyepetizerFlutterOwner({
    this.uid,
    this.nickname,
    this.avatar,
    this.city = '',
  });

  factory EyepetizerFlutterOwner.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterOwner(
        uid: EyepetizerFlutterJson.asNullableInt(json['uid']),
        nickname: EyepetizerFlutterJson.asNullableString(json['nickname']),
        avatar: EyepetizerFlutterJson.asNullableString(json['avatar']),
        city: json['city'] == null
            ? ''
            : EyepetizerFlutterJson.asString(json['city']),
      );

  final int? uid;
  final String? nickname;
  final String? avatar;
  final String city;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'nickname': nickname,
    'avatar': avatar,
    'city': city,
  };
}
