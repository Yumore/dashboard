import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/video_poster_bean.dart` → `VideoPosterBean`.
class EyepetizerFlutterVideoPoster {
  const EyepetizerFlutterVideoPoster({this.scale, this.url, this.fileSizeStr});

  factory EyepetizerFlutterVideoPoster.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterVideoPoster(
        scale: _asNullableDouble(json['scale']),
        url: EyepetizerFlutterJson.asNullableString(json['url']),
        fileSizeStr: EyepetizerFlutterJson.asNullableString(
          json['fileSizeStr'],
        ),
      );

  final double? scale;
  final String? url;
  final String? fileSizeStr;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'scale': scale,
    'url': url,
    'fileSizeStr': fileSizeStr,
  };

  static double? _asNullableDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
