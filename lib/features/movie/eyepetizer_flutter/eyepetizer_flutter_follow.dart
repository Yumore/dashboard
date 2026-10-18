import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/person_mainpage.dart` → `Follow`.
class EyepetizerFlutterFollow {
  const EyepetizerFlutterFollow({this.itemType, this.itemId, this.followed});

  factory EyepetizerFlutterFollow.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterFollow(
        itemType: EyepetizerFlutterJson.asNullableString(json['itemType']),
        itemId: EyepetizerFlutterJson.asNullableInt(json['itemId']),
        followed: json['followed'] is bool ? json['followed'] as bool : null,
      );

  final String? itemType;
  final int? itemId;
  final bool? followed;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'itemType': itemType,
    'itemId': itemId,
    'followed': followed,
  };
}
