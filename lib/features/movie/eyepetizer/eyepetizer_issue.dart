import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_paging.dart';

/// The `itemList` + `nextPageUrl` envelope returned by `v4/video/related`,
/// `v1/search`, `v4/categories/videoList` and `v4/rankList`
/// (`common_item_model.dart:1`).
class EyepetizerIssue extends EyepetizerPaging<EyepetizerItem> {
  EyepetizerIssue({
    super.itemList,
    super.nextPageUrl,
    this.total = 0,
    this.count = 0,
    this.date = 0,
    this.publishTime = 0,
    this.releaseTime = 0,
    this.type = '',
  });

  factory EyepetizerIssue.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerIssue(
      itemList: EyepetizerJson.asMapList(
        map['itemList'],
      ).map(EyepetizerItem.fromJson).toList(),
      nextPageUrl: EyepetizerJson.asNullableString(map['nextPageUrl']),
      total: EyepetizerJson.asInt(map['total']),
      count: EyepetizerJson.asInt(map['count']),
      date: EyepetizerJson.asInt(map['date']),
      publishTime: EyepetizerJson.asInt(map['publishTime']),
      releaseTime: EyepetizerJson.asInt(map['releaseTime']),
      type: EyepetizerJson.asString(map['type']),
    );
  }

  /// Total hits for a search, total rows for a category page.
  final int total;

  final int count;
  final int date;
  final int publishTime;
  final int releaseTime;
  final String type;
}
