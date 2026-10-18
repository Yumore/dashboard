import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_tab_info.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_user_info.dart';

/// `lib/model/person_mainpage.dart` → `PersonMainModel`.
///
/// The `pgcInfo` fallback is load-bearing: `GET /api/v5/userInfo/tab` answers
/// with `userInfo` for a normal account and with `pgcInfo` for a PGC account,
/// and the source picked whichever was present. The port keeps that key order
/// (`userInfo` wins when both exist).
class EyepetizerFlutterPersonMainModel {
  const EyepetizerFlutterPersonMainModel({this.tabInfo, this.userInfo});

  factory EyepetizerFlutterPersonMainModel.fromJson(Map<String, dynamic> json) {
    final userInfo = json['userInfo'] ?? json['pgcInfo'];
    return EyepetizerFlutterPersonMainModel(
      tabInfo: json['tabInfo'] is Map
          ? EyepetizerFlutterTabInfo.fromJson(
              EyepetizerFlutterJson.asMap(json['tabInfo']),
            )
          : null,
      userInfo: userInfo is Map
          ? EyepetizerFlutterUserInfo.fromJson(
              EyepetizerFlutterJson.asMap(userInfo),
            )
          : null,
    );
  }

  final EyepetizerFlutterTabInfo? tabInfo;
  final EyepetizerFlutterUserInfo? userInfo;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'tabInfo': tabInfo?.toJson(),
    'userInfo': userInfo?.toJson(),
  };
}
