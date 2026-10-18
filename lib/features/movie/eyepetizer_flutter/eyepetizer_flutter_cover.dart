import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/cover.dart`.
class EyepetizerFlutterCover {
  const EyepetizerFlutterCover({
    this.feed,
    this.detail,
    this.blurred,
    this.homepage,
  });

  factory EyepetizerFlutterCover.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterCover(
        feed: EyepetizerFlutterJson.asNullableString(json['feed']),
        detail: EyepetizerFlutterJson.asNullableString(json['detail']),
        blurred: EyepetizerFlutterJson.asNullableString(json['blurred']),
        homepage: EyepetizerFlutterJson.asNullableString(json['homepage']),
      );

  final String? feed;
  final String? detail;
  final String? blurred;
  final String? homepage;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'feed': feed,
    'detail': detail,
    'blurred': blurred,
    'homepage': homepage,
  };
}
