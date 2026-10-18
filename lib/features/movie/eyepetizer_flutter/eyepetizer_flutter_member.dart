import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_device.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/login/login.dart` → `Member`.
///
/// Two source behaviours are kept exactly:
/// * `devices` missing from the payload becomes an **empty list**, never null
///   (`devices == null ? List<Device>() : ...`);
/// * `roles` is read with `cast<String>()`, so a null `roles` (or one holding
///   non-strings) threw. The port degrades it to an empty list instead.
class EyepetizerFlutterMember {
  const EyepetizerFlutterMember({
    this.uid,
    this.nick,
    this.avatar,
    this.username,
    this.telephone,
    this.devices = const <EyepetizerFlutterDevice>[],
    this.roles = const <String>[],
    this.registerSource,
    this.needUpdatePassword,
  });

  factory EyepetizerFlutterMember.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterMember(
        uid: EyepetizerFlutterJson.asNullableInt(json['uid']),
        nick: EyepetizerFlutterJson.asNullableString(json['nick']),
        avatar: EyepetizerFlutterJson.asNullableString(json['avatar']),
        username: EyepetizerFlutterJson.asNullableString(json['username']),
        telephone: EyepetizerFlutterJson.asNullableString(json['telephone']),
        devices: EyepetizerFlutterJson.asMapList(
          json['devices'],
        ).map(EyepetizerFlutterDevice.fromJson).toList(growable: false),
        roles: EyepetizerFlutterJson.asStringList(json['roles']),
        registerSource: EyepetizerFlutterJson.asNullableString(
          json['registerSource'],
        ),
        needUpdatePassword: json['needUpdatePassword'] is bool
            ? json['needUpdatePassword'] as bool
            : null,
      );

  final int? uid;
  final String? nick;
  final String? avatar;
  final String? username;
  final String? telephone;
  final List<EyepetizerFlutterDevice> devices;
  final List<String> roles;
  final String? registerSource;
  final bool? needUpdatePassword;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'nick': nick,
    'avatar': avatar,
    'username': username,
    'telephone': telephone,
    'devices': devices.map((device) => device.toJson()).toList(),
    'roles': roles,
    'registerSource': registerSource,
    'needUpdatePassword': needUpdatePassword,
  };
}
