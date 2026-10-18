import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One ranked comic.
///
/// Serves both `getIndexRankData` (`rise_rank` is an int there) and
/// `getRankDataDetials` (`rise_rank` is a String and `comic_shortdesc` is
/// present). The source duplicated the whole class per endpoint; this port
/// keeps one model and coerces `rise_rank` to String.
///
/// Source: `lib/models/rank_list.dart` → `ListSub` and
/// `lib/models/rank_data_detials.dart` → `Data`.
class ManhuataiRankComic {
  const ManhuataiRankComic({
    required this.countDay,
    required this.comicId,
    required this.comicName,
    required this.comicUrlid,
    required this.authorName,
    required this.sortTypelist,
    required this.lastchapterId,
    required this.lastchapterUrlid,
    required this.lastchapterTitle,
    required this.lastChapterId,
    required this.lastChapterNewid,
    required this.lastChapterName,
    required this.comicFeature,
    required this.comicShortdesc,
    required this.comicScore,
    required this.countNum,
    required this.riseRank,
  });

  final int countDay;
  final int comicId;
  final String comicName;
  final String comicUrlid;
  final String authorName;
  final String sortTypelist;
  final String lastchapterId;
  final String lastchapterUrlid;
  final String lastchapterTitle;
  final String lastChapterId;
  final String lastChapterNewid;
  final String lastChapterName;
  final String comicFeature;

  /// Only present on rank-detail rows; defaults to `''`.
  final String comicShortdesc;
  final double comicScore;
  final String countNum;

  /// Rank movement; the backend sends this as either an int or a String.
  final String riseRank;

  factory ManhuataiRankComic.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiRankComic(
      countDay: ManhuataiJson.asInt(source['count_day']),
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      comicUrlid: ManhuataiJson.asString(source['comic_urlid']),
      authorName: ManhuataiJson.asString(source['author_name']),
      sortTypelist: ManhuataiJson.asString(source['sort_typelist']),
      lastchapterId: ManhuataiJson.asString(source['lastchapter_id']),
      lastchapterUrlid: ManhuataiJson.asString(source['lastchapter_urlid']),
      lastchapterTitle: ManhuataiJson.asString(source['lastchapter_title']),
      lastChapterId: ManhuataiJson.asString(source['last_chapter_id']),
      lastChapterNewid: ManhuataiJson.asString(source['last_chapter_newid']),
      lastChapterName: ManhuataiJson.asString(source['last_chapter_name']),
      comicFeature: ManhuataiJson.asString(source['comic_feature']),
      comicShortdesc: ManhuataiJson.asString(source['comic_shortdesc']),
      comicScore: ManhuataiJson.asDouble(source['comic_score']),
      countNum: ManhuataiJson.asString(source['count_num']),
      riseRank: ManhuataiJson.asDynamicString(source['rise_rank']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'count_day': countDay,
        'comic_id': comicId,
        'comic_name': comicName,
        'comic_urlid': comicUrlid,
        'author_name': authorName,
        'sort_typelist': sortTypelist,
        'lastchapter_id': lastchapterId,
        'lastchapter_urlid': lastchapterUrlid,
        'lastchapter_title': lastchapterTitle,
        'last_chapter_id': lastChapterId,
        'last_chapter_newid': lastChapterNewid,
        'last_chapter_name': lastChapterName,
        'comic_feature': comicFeature,
        'comic_shortdesc': comicShortdesc,
        'comic_score': comicScore,
        'count_num': countNum,
        'rise_rank': riseRank,
      };
}
