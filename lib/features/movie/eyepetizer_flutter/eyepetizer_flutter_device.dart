import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/login/login.dart` → `Device`.
class EyepetizerFlutterDevice {
  const EyepetizerFlutterDevice({this.id, this.udid});

  factory EyepetizerFlutterDevice.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterDevice(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        udid: EyepetizerFlutterJson.asNullableString(json['udid']),
      );

  final int? id;
  final String? udid;

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'udid': udid};
}
