import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/upload_picture.dart`'s file-local `Item`.
///
/// The source reused the name `Item` for this four-field upload response
/// inside `upload_picture.dart`, shadowing `model/item.dart`'s `Item`. The
/// port names it [EyepetizerFlutterUploadItem] so the two can never be
/// confused: `EditPersonDataPage` reads `value.item.url` from here, not from a
/// feed item.
class EyepetizerFlutterUploadItem {
  const EyepetizerFlutterUploadItem({
    this.width,
    this.height,
    this.format,
    this.url,
  });

  factory EyepetizerFlutterUploadItem.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterUploadItem(
        width: EyepetizerFlutterJson.asNullableInt(json['width']),
        height: EyepetizerFlutterJson.asNullableInt(json['height']),
        format: EyepetizerFlutterJson.asNullableString(json['format']),
        url: EyepetizerFlutterJson.asNullableString(json['url']),
      );

  final int? width;
  final int? height;
  final String? format;
  final String? url;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'width': width,
    'height': height,
    'format': format,
    'url': url,
  };
}
