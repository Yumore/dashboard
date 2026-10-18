import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_group.dart';

/// Response of `getIndexRankData` — the home ranking tab.
///
/// Source: `lib/models/rank_list.dart` → `RankList`.
class ManhuataiRankList {
  const ManhuataiRankList({
    required this.status,
    required this.msg,
    required this.groups,
  });

  final int status;
  final String msg;
  final List<ManhuataiRankGroup> groups;

  static const ManhuataiRankList empty = ManhuataiRankList(
    status: 0,
    msg: '',
    groups: <ManhuataiRankGroup>[],
  );

  factory ManhuataiRankList.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankList(
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
      groups: ManhuataiJson.maps(source['data'])
          .map(ManhuataiRankGroup.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'msg': msg,
        'data': groups.map((group) => group.toJson()).toList(),
      };
}
