import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter_image.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One chapter of a comic.
///
/// `chapter_id` is a String while `chapter_topic_id` is the int used for
/// navigation and read-history bookkeeping.
///
/// Source: `lib/models/comic_info_body.dart` → `Comic_chapter`.
class ManhuataiChapter {
  const ManhuataiChapter({
    required this.chapterName,
    required this.chapterId,
    required this.chapterTopicId,
    required this.createDate,
    required this.islock,
    required this.chapterShareUrl,
    required this.downloadPrice,
    required this.price,
    required this.chapterImage,
    required this.isbuy,
    required this.startNum,
    required this.endNum,
    required this.chapterDomain,
    required this.sourceUrl,
    required this.rule,
    required this.webview,
    required this.showSpiltline,
  });

  final String chapterName;
  final String chapterId;
  final int chapterTopicId;
  final int createDate;
  final int islock;
  final String chapterShareUrl;
  final int downloadPrice;
  final int price;
  final ManhuataiChapterImage chapterImage;
  final int isbuy;
  final int startNum;
  final int endNum;
  final String chapterDomain;
  final String sourceUrl;
  final String rule;
  final String webview;
  final int showSpiltline;

  /// `islock != 0` marks a paid/locked chapter.
  bool get isLocked => islock != 0;

  /// Number of page slots the image template yields: the source iterated
  /// `1 .. startNum + endNum - 1`.
  int get pageCount {
    final total = startNum + endNum - 1;
    return total > 0 ? total : 0;
  }

  factory ManhuataiChapter.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiChapter(
      chapterName: ManhuataiJson.asString(source['chapter_name']),
      chapterId: ManhuataiJson.asString(source['chapter_id']),
      chapterTopicId: ManhuataiJson.asInt(source['chapter_topic_id']),
      createDate: ManhuataiJson.asInt(source['create_date']),
      islock: ManhuataiJson.asInt(source['islock']),
      chapterShareUrl: ManhuataiJson.asString(source['chapter_share_url']),
      downloadPrice: ManhuataiJson.asInt(source['download_price']),
      price: ManhuataiJson.asInt(source['price']),
      chapterImage: source['chapter_image'] == null
          ? ManhuataiChapterImage.empty
          : ManhuataiChapterImage.fromJson(
              ManhuataiJson.map(source['chapter_image']),
            ),
      isbuy: ManhuataiJson.asInt(source['isbuy']),
      startNum: ManhuataiJson.asInt(source['start_num']),
      endNum: ManhuataiJson.asInt(source['end_num']),
      chapterDomain: ManhuataiJson.asString(source['chapter_domain']),
      sourceUrl: ManhuataiJson.asString(source['source_url']),
      rule: ManhuataiJson.asString(source['rule']),
      webview: ManhuataiJson.asString(source['webview']),
      showSpiltline: ManhuataiJson.asInt(source['show_spiltline']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'chapter_name': chapterName,
        'chapter_id': chapterId,
        'chapter_topic_id': chapterTopicId,
        'create_date': createDate,
        'islock': islock,
        'chapter_share_url': chapterShareUrl,
        'download_price': downloadPrice,
        'price': price,
        'chapter_image': chapterImage.toJson(),
        'isbuy': isbuy,
        'start_num': startNum,
        'end_num': endNum,
        'chapter_domain': chapterDomain,
        'source_url': sourceUrl,
        'rule': rule,
        'webview': webview,
        'show_spiltline': showSpiltline,
      };
}
