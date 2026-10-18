import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_upload_item.dart';

/// `lib/model/upload_picture.dart` → `UploadPicture`.
///
/// The upload response's shape differs from the feed: `errorCode` /
/// `errorMessage` (not `error` / `msg`), and the URL comes from
/// [EyepetizerFlutterUploadItem].
class EyepetizerFlutterUploadPicture {
  const EyepetizerFlutterUploadPicture({
    this.errorCode,
    this.errorMessage,
    this.item,
  });

  factory EyepetizerFlutterUploadPicture.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterUploadPicture(
        errorCode: EyepetizerFlutterJson.asNullableInt(json['errorCode']),
        errorMessage: EyepetizerFlutterJson.asNullableString(
          json['errorMessage'],
        ),
        item: json['item'] is Map
            ? EyepetizerFlutterUploadItem.fromJson(
                EyepetizerFlutterJson.asMap(json['item']),
              )
            : null,
      );

  final int? errorCode;
  final String? errorMessage;
  final EyepetizerFlutterUploadItem? item;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'errorCode': errorCode,
    'errorMessage': errorMessage,
    'item': item?.toJson(),
  };
}
