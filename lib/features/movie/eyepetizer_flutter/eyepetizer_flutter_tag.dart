import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/detail.dart` → `Tag`.
class EyepetizerFlutterTag {
  const EyepetizerFlutterTag({
    this.id,
    this.name,
    this.actionUrl,
    this.desc,
    this.headerImage,
  });

  factory EyepetizerFlutterTag.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterTag(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        name: EyepetizerFlutterJson.asNullableString(json['name']),
        actionUrl: EyepetizerFlutterJson.asNullableString(json['actionUrl']),
        desc: EyepetizerFlutterJson.asNullableString(json['desc']),
        headerImage: EyepetizerFlutterJson.asNullableString(
          json['headerImage'],
        ),
      );

  final int? id;
  final String? name;
  final String? actionUrl;
  final String? desc;
  final String? headerImage;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'actionUrl': actionUrl,
    'desc': desc,
    'headerImage': headerImage,
  };
}
