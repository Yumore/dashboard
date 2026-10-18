import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/base_data.dart` — the account host's minimal `{error, msg}` body.
///
/// The source declared `int error` pre-null-safety, so a missing `error` was a
/// null that still compared unequal to `0` (i.e. "failed"). Keeping `error`
/// nullable preserves that reading without a magic default.
class EyepetizerFlutterBaseData {
  const EyepetizerFlutterBaseData({this.error, this.msg});

  factory EyepetizerFlutterBaseData.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterBaseData(
        error: EyepetizerFlutterJson.asNullableInt(json['error']),
        msg: EyepetizerFlutterJson.asNullableString(json['msg']),
      );

  final int? error;
  final String? msg;

  /// True when the account host reported success (`error == 0`).
  bool get isSuccess => error == 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'error': error,
    'msg': msg,
  };
}
