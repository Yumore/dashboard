import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// A single cover card inside a home-page section.
///
/// Source: `lib/models/book_list.dart` → `Comic_info`.
class ManhuataiComic {
  const ManhuataiComic({
    required this.comicId,
    required this.comicName,
    required this.content,
    required this.totalViewNum,
    required this.updateTime,
    required this.score,
    required this.url,
    required this.imgUrl,
    required this.lastComicChapterName,
    required this.ordernum,
    required this.comicType,
  });

  final int comicId;
  final String comicName;
  final String content;

  /// Numeric on most endpoints, a String on the rank endpoints — the source
  /// model keeps it `dynamic`, this port keeps the raw string.
  final String totalViewNum;
  final String updateTime;
  final String score;
  final String url;
  final String imgUrl;
  final String lastComicChapterName;
  final int ordernum;
  final List<String> comicType;

  factory ManhuataiComic.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiComic(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      content: ManhuataiJson.asString(source['content']),
      totalViewNum: ManhuataiJson.asDynamicString(source['total_view_num']),
      updateTime: ManhuataiJson.asDynamicString(source['update_time']),
      score: ManhuataiJson.asDynamicString(source['score']),
      url: ManhuataiJson.asString(source['url']),
      imgUrl: ManhuataiJson.asString(source['img_url']),
      lastComicChapterName:
          ManhuataiJson.asString(source['last_comic_chapter_name']),
      ordernum: ManhuataiJson.asInt(source['ordernum']),
      comicType: ManhuataiJson.asStringList(source['comic_type']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'content': content,
        'total_view_num': totalViewNum,
        'update_time': updateTime,
        'score': score,
        'url': url,
        'img_url': imgUrl,
        'last_comic_chapter_name': lastComicChapterName,
        'ordernum': ordernum,
        'comic_type': comicType,
      };
}
