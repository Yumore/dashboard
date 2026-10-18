import 'package:dashboard/features/comic/manhuatai/manhuatai_influence_user.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Heat/statistics payload of `getcomicinfo_influence`.
///
/// The source also carried a `call_data` block (per-user coin/reward flags);
/// it belongs to the login/charge flow, which this port does not migrate, so it
/// is intentionally dropped.
///
/// Source: `lib/models/comic_info_influence.dart` → `Data`.
class ManhuataiInfluenceData {
  const ManhuataiInfluenceData({
    required this.outList,
    required this.insiderList,
  });

  /// Rank positions of the current user, e.g. `[3, 12]`.
  final List<int> outList;
  final List<ManhuataiInfluenceUser> insiderList;

  static const ManhuataiInfluenceData empty = ManhuataiInfluenceData(
    outList: <int>[],
    insiderList: <ManhuataiInfluenceUser>[],
  );

  factory ManhuataiInfluenceData.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiInfluenceData(
      outList: ManhuataiJson.asIntList(source['out_list']),
      insiderList: ManhuataiJson.maps(source['insider_list'])
          .map(ManhuataiInfluenceUser.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'out_list': outList,
        'insider_list': insiderList.map((user) => user.toJson()).toList(),
      };
}
