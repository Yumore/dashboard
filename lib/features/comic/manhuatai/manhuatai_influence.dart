import 'package:dashboard/features/comic/manhuatai/manhuatai_influence_data.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Response of `getcomicinfo_influence`.
///
/// Source: `lib/models/comic_info_influence.dart` → `ComicInfoInfluence`.
class ManhuataiInfluence {
  const ManhuataiInfluence({
    required this.data,
    required this.status,
    required this.msg,
  });

  final ManhuataiInfluenceData data;
  final int status;
  final String msg;

  static const ManhuataiInfluence empty = ManhuataiInfluence(
    data: ManhuataiInfluenceData.empty,
    status: 0,
    msg: '',
  );

  factory ManhuataiInfluence.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiInfluence(
      data: ManhuataiInfluenceData.fromJson(
        ManhuataiJson.map(source['data']),
      ),
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data.toJson(),
        'status': status,
        'msg': msg,
      };
}
