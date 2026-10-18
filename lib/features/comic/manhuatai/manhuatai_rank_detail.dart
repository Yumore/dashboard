import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_comic.dart';

/// Response of `getRankDataDetials` — a flat ranked comic list.
///
/// Source: `lib/models/rank_data_detials.dart` → `RankDataDetials`.
class ManhuataiRankDetail {
  const ManhuataiRankDetail({
    required this.status,
    required this.msg,
    required this.data,
  });

  final int status;
  final String msg;
  final List<ManhuataiRankComic> data;

  static const ManhuataiRankDetail empty = ManhuataiRankDetail(
    status: 0,
    msg: '',
    data: <ManhuataiRankComic>[],
  );

  factory ManhuataiRankDetail.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankDetail(
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
      data: ManhuataiJson.maps(source['data'])
          .map(ManhuataiRankComic.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'msg': msg,
        'data': data.map((item) => item.toJson()).toList(),
      };
}
