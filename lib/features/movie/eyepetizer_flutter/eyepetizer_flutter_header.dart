import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/header.dart`.
class EyepetizerFlutterHeader {
  const EyepetizerFlutterHeader({
    this.id,
    this.title,
    this.icon,
    this.description,
  });

  factory EyepetizerFlutterHeader.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterHeader(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        title: EyepetizerFlutterJson.asNullableString(json['title']),
        icon: EyepetizerFlutterJson.asNullableString(json['icon']),
        description: EyepetizerFlutterJson.asNullableString(
          json['description'],
        ),
      );

  final int? id;
  final String? title;
  final String? icon;
  final String? description;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'icon': icon,
    'description': description,
  };
}
