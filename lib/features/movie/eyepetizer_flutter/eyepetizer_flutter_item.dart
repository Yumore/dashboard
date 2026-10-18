import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/item.dart` → `Item`.
///
/// `type` is the dispatch key for the card factory (`followCard`,
/// `communityColumnsCard`, ...) and `data` may be absent.
class EyepetizerFlutterItem {
  const EyepetizerFlutterItem({this.type, this.data});

  factory EyepetizerFlutterItem.fromJson(Map<String, dynamic> json) =>
      EyepetizerFlutterItem(
        type: EyepetizerFlutterJson.asNullableString(json['type']),
        data: json['data'] is Map
            ? EyepetizerFlutterItemData.fromJson(
                EyepetizerFlutterJson.asMap(json['data']),
              )
            : null,
      );

  final String? type;
  final EyepetizerFlutterItemData? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'data': data?.toJson(),
  };
}
