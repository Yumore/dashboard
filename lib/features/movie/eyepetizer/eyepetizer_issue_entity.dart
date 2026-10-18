import 'package:dashboard/features/movie/eyepetizer/eyepetizer_issue.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_paging.dart';

/// The `v2/feed` envelope (`common_item_model.dart:420`).
///
/// The home feed never returns a flat `itemList`: it returns an `issueList`
/// whose **first** issue carries the rows. The source flattened that first issue
/// in `fromJson` and the port keeps the same shape so callers cannot diverge.
class EyepetizerIssueEntity extends EyepetizerPaging<EyepetizerItem> {
  EyepetizerIssueEntity({
    super.itemList,
    super.nextPageUrl,
    this.nextPublishTime = 0,
    this.newestIssueType = '',
    this.issueList = const <EyepetizerIssue>[],
  });

  factory EyepetizerIssueEntity.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    final issues = EyepetizerJson.asMapList(
      map['issueList'],
    ).map(EyepetizerIssue.fromJson).toList(growable: false);
    return EyepetizerIssueEntity(
      issueList: issues,
      itemList: issues.isEmpty
          ? <EyepetizerItem>[]
          : List<EyepetizerItem>.of(issues.first.itemList),
      nextPageUrl: EyepetizerJson.asNullableString(map['nextPageUrl']),
      nextPublishTime: EyepetizerJson.asInt(map['nextPublishTime']),
      newestIssueType: EyepetizerJson.asString(map['newestIssueType']),
    );
  }

  final int nextPublishTime;
  final String newestIssueType;
  final List<EyepetizerIssue> issueList;
}
