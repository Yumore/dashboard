import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_header.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/base_list_data.dart` → `BaseListData`.
///
/// This is the object the local cache stores as one JSON string per tag, so
/// [toJson] must stay key-for-key with the source: `code`, `itemList`,
/// `nextPageUrl`, `header`.
class EyepetizerFlutterBaseListData {
  const EyepetizerFlutterBaseListData({
    this.code = 0,
    this.itemList = const <EyepetizerFlutterItem>[],
    this.nextPageUrl,
    this.header,
  });

  factory EyepetizerFlutterBaseListData.fromJson(Map<String, dynamic> json) {
    final header = json['header'];
    return EyepetizerFlutterBaseListData(
      code: json['code'] == null
          ? 0
          : EyepetizerFlutterJson.asInt(json['code']),
      itemList: EyepetizerFlutterJson.asMapList(
        json['itemList'],
      ).map(EyepetizerFlutterItem.fromJson).toList(),
      nextPageUrl: EyepetizerFlutterJson.asNullableString(json['nextPageUrl']),
      header: header is Map
          ? EyepetizerFlutterHeader.fromJson(
              EyepetizerFlutterJson.asMap(header),
            )
          : null,
    );
  }

  final int code;
  final List<EyepetizerFlutterItem> itemList;
  final String? nextPageUrl;
  final EyepetizerFlutterHeader? header;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'itemList': itemList.map((item) => item.toJson()).toList(),
    'nextPageUrl': nextPageUrl,
    'header': header?.toJson(),
  };

  @override
  String toString() =>
      'EyepetizerFlutterBaseListData{code: $code, '
      'itemList: $itemList, nextPageUrl: $nextPageUrl, header: $header}';
}
