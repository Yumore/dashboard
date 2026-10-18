import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';

/// One entry of `playInfo[].urlList` (`common_item_model.dart:408`).
///
/// The source's generated class name was
/// `IssueIssuelistItemlistDataPlayinfoUrllist`; the port uses the honest name.
class EyepetizerPlayUrl {
  const EyepetizerPlayUrl({this.name = '', this.url = '', this.size = 0});

  factory EyepetizerPlayUrl.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerPlayUrl(
      name: EyepetizerJson.asString(map['name']),
      url: EyepetizerJson.asString(map['url']),
      size: EyepetizerJson.asInt(map['size']),
    );
  }

  /// Quality label as served, e.g. `标清` / `高清`.
  final String name;

  /// Absolute stream URL.
  final String url;

  /// Vertical resolution, e.g. 480 / 720.
  final int size;
}
