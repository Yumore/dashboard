import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_content_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/content.dart` → `Content`.
///
/// `communityColumnsCard` items carry their payload here: the staggered card
/// reads `content.data.cover.feed`, `.owner`, `.consumption`, `.description`
/// and `.resourceType`.
class EyepetizerFlutterContent {
  const EyepetizerFlutterContent({this.type, this.data});

  factory EyepetizerFlutterContent.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterContent(
        type: EyepetizerFlutterJson.asNullableString(json['type']),
        data: json['data'] is Map
            ? EyepetizerFlutterContentData.fromJson(
                EyepetizerFlutterJson.asMap(json['data']),
              )
            : null,
      );

  final String? type;
  final EyepetizerFlutterContentData? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'data': data?.toJson(),
  };
}
