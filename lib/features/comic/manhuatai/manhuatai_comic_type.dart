import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// A tag attached to a comic (`comic_type_new`).
///
/// Source: `lib/models/comic_info_body.dart` → `Comic_type_new`.
class ManhuataiComicType {
  const ManhuataiComicType({
    required this.id,
    required this.name,
    required this.urlid,
  });

  final int id;
  final String name;
  final String urlid;

  factory ManhuataiComicType.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiComicType(
      id: ManhuataiJson.asInt(source['id']),
      name: ManhuataiJson.asString(source['name']),
      urlid: ManhuataiJson.asString(source['urlid']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'urlid': urlid,
      };
}
