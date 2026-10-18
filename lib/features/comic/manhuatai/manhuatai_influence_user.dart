import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One user entry of `getcomicinfo_influence` (`insider_list`).
///
/// Source: `lib/models/comic_info_influence.dart` → `Insider_list`.
class ManhuataiInfluenceUser {
  const ManhuataiInfluenceUser({
    required this.uid,
    required this.counts,
    required this.uname,
    required this.level,
    required this.isvip,
  });

  final int uid;
  final int counts;

  /// `Uname` — deliberately capitalised by the backend.
  final String uname;
  final int level;
  final int isvip;

  factory ManhuataiInfluenceUser.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiInfluenceUser(
      uid: ManhuataiJson.asInt(source['uid']),
      counts: ManhuataiJson.asInt(source['counts']),
      uname: ManhuataiJson.asString(source['Uname']),
      level: ManhuataiJson.asInt(source['level']),
      isvip: ManhuataiJson.asInt(source['isvip']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': uid,
        'counts': counts,
        'Uname': uname,
        'level': level,
        'isvip': isvip,
      };
}
