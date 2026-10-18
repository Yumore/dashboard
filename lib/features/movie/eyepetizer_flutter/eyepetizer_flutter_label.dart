import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/item_banner.dart` → `Label`.
class EyepetizerFlutterLabel {
  const EyepetizerFlutterLabel({this.text});

  factory EyepetizerFlutterLabel.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterLabel(
        text: EyepetizerFlutterJson.asNullableString(json['text']),
      );

  final String? text;

  Map<String, dynamic> toJson() => <String, dynamic>{'text': text};
}
