import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/item_data.dart`'s file-local `Detail` (five fields).
///
/// The source had two classes named `Detail`: this small one inside
/// `item_data.dart` and the rich one in `model/detail.dart`. The port gives
/// them distinct names ([EyepetizerFlutterItemDetail] and
/// `EyepetizerFlutterDetail`) so the shadowing cannot recur.
class EyepetizerFlutterItemDetail {
  const EyepetizerFlutterItemDetail({
    this.id,
    this.icon,
    this.title,
    this.description,
    this.url,
  });

  factory EyepetizerFlutterItemDetail.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterItemDetail(
        id: EyepetizerFlutterJson.asNullableInt(json['id']),
        icon: EyepetizerFlutterJson.asNullableString(json['icon']),
        title: EyepetizerFlutterJson.asNullableString(json['title']),
        description: EyepetizerFlutterJson.asNullableString(
          json['description'],
        ),
        url: EyepetizerFlutterJson.asNullableString(json['url']),
      );

  final int? id;
  final String? icon;
  final String? title;
  final String? description;
  final String? url;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'icon': icon,
    'title': title,
    'description': description,
    'url': url,
  };
}
