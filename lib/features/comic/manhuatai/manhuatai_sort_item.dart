import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One comic of the category list (`getsortlist`).
///
/// Note `comic_type` here is a single String (unlike the tag list used by other
/// endpoints) — verified against the source model.
///
/// Source: `lib/models/sort_list.dart` → `Data`.
class ManhuataiSortItem {
  const ManhuataiSortItem({
    required this.comicId,
    required this.comicName,
    required this.lastChapterName,
    required this.comicType,
    required this.comicNewid,
  });

  final int comicId;
  final String comicName;
  final String lastChapterName;
  final String comicType;
  final String comicNewid;

  factory ManhuataiSortItem.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiSortItem(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      lastChapterName: ManhuataiJson.asString(source['last_chapter_name']),
      comicType: ManhuataiJson.asDynamicString(source['comic_type']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'last_chapter_name': lastChapterName,
        'comic_type': comicType,
        'comic_newid': comicNewid,
      };
}
