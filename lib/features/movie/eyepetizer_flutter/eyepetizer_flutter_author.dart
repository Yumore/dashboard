import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/author.dart`.
///
/// `icon` keeps the source's `json['icon'] == null ? "" : ...` fallback.
class EyepetizerFlutterAuthor {
  const EyepetizerFlutterAuthor({
    this.id,
    this.icon = '',
    this.name,
    this.description,
  });

  factory EyepetizerFlutterAuthor.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterAuthor(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        icon: json['icon'] == null
            ? ''
            : EyepetizerFlutterJson.asString(json['icon']),
        name: EyepetizerFlutterJson.asNullableString(json['name']),
        description: EyepetizerFlutterJson.asNullableString(
          json['description'],
        ),
      );

  final int? id;
  final String icon;
  final String? name;
  final String? description;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'icon': icon,
    'name': name,
    'description': description,
  };
}
