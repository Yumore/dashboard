import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_header.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_item_banner_data.dart';
import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';

/// `lib/model/item_banner.dart` → `ItemBanner`.
///
/// Deliberate deviation: the source assigned `header = json['header']` raw, so
/// after a local-cache round trip (JSON decode → `Map` stored in a `Header`
/// field) the type was a lie. The port parses it into
/// [EyepetizerFlutterHeader] when it is a map, which is what makes the cached
/// `videoCollectionOfHorizontalScrollCard` payload usable again.
class EyepetizerFlutterItemBanner {
  const EyepetizerFlutterItemBanner({this.type, this.header, this.data});

  factory EyepetizerFlutterItemBanner.fromJson(Map<String, dynamic> json) {
    final header = json['header'];
    return EyepetizerFlutterItemBanner(
      type: EyepetizerFlutterJson.asNullableString(json['type']),
      header: header is Map
          ? EyepetizerFlutterHeader.fromJson(
              EyepetizerFlutterJson.asMap(header),
            )
          : null,
      data: json['data'] is Map
          ? EyepetizerFlutterItemBannerData.fromJson(
              EyepetizerFlutterJson.asMap(json['data']),
            )
          : null,
    );
  }

  final String? type;
  final EyepetizerFlutterHeader? header;
  final EyepetizerFlutterItemBannerData? data;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'header': header?.toJson(),
    'data': data?.toJson(),
  };
}
