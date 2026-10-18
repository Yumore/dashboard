import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One entry of the top-search list (`gettopsearch`).
///
/// The endpoint returns a bare JSON array, which the source mapped through
/// `getHotSearchList`. This port keeps that behaviour in `ManhuataiSource`.
///
/// Source: `lib/models/hot_search.dart` → `HotSearch`.
class ManhuataiHotSearch {
  const ManhuataiHotSearch({
    required this.comicId,
    required this.comicName,
    required this.lastChapterName,
    required this.comicNewid,
  });

  final int comicId;
  final String comicName;
  final String lastChapterName;
  final String comicNewid;

  factory ManhuataiHotSearch.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiHotSearch(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      lastChapterName: ManhuataiJson.asString(source['last_chapter_name']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'last_chapter_name': lastChapterName,
        'comic_newid': comicNewid,
      };
}
