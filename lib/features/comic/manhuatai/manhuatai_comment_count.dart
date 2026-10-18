import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Comment counter of `comment/count`.
///
/// The endpoint replies `{data, status, msg}` where `data` is the raw count.
///
/// Source: `lib/models/comic_comment_count.dart` → `ComicCommentCount`.
class ManhuataiCommentCount {
  const ManhuataiCommentCount({
    required this.data,
    required this.status,
    required this.msg,
  });

  final int data;
  final int status;
  final String msg;

  static const ManhuataiCommentCount empty =
      ManhuataiCommentCount(data: 0, status: 0, msg: '');

  factory ManhuataiCommentCount.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiCommentCount(
      data: ManhuataiJson.asInt(source['data']),
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data,
        'status': status,
        'msg': msg,
      };
}
