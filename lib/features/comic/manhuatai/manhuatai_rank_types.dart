import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_rank_options.dart';

/// Response of `getRankTypes`.
///
/// Source: `lib/models/rank_types.dart` → `RankTypes`.
class ManhuataiRankTypes {
  const ManhuataiRankTypes({
    required this.status,
    required this.msg,
    required this.data,
  });

  final int status;
  final String msg;
  final ManhuataiRankOptions data;

  static const ManhuataiRankTypes empty = ManhuataiRankTypes(
    status: 0,
    msg: '',
    data: ManhuataiRankOptions.empty,
  );

  factory ManhuataiRankTypes.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankTypes(
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
      data: ManhuataiRankOptions.fromJson(ManhuataiJson.map(source['data'])),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'msg': msg,
        'data': data.toJson(),
      };
}
