import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_member.dart';

/// `lib/model/login/login.dart` → `Login`.
///
/// This is the object `PrefsUtil.putObject(PrefsKey.USER_DATA, value)` stored
/// after a successful login, and the one `MineBloc.getUserData` reads back.
class EyepetizerFlutterLogin {
  const EyepetizerFlutterLogin({this.error, this.msg, this.member});

  factory EyepetizerFlutterLogin.fromJson(Map<String, dynamic> json) {
    final member = json['member'];
    return EyepetizerFlutterLogin(
      error: EyepetizerFlutterJson.asNullableInt(json['error']),
      msg: EyepetizerFlutterJson.asNullableString(json['msg']),
      member: member is Map
          ? EyepetizerFlutterMember.fromJson(
              EyepetizerFlutterJson.asMap(member),
            )
          : null,
    );
  }

  final int? error;
  final String? msg;
  final EyepetizerFlutterMember? member;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'error': error,
    'msg': msg,
    'member': member?.toJson(),
  };
}
