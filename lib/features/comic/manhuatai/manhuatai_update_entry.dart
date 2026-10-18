import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One comic row of the update feed (`updatelist`).
///
/// The source declared two nearly identical classes (`Info` for `update`,
/// `Today` for `today`); the only difference is `yesterday_view_num`, which
/// exists only on `today` rows. This port uses one class with a nullable
/// [yesterdayViewNum] instead of duplicating the 18 fields.
///
/// Source: `lib/models/update_list.dart` → `Info` / `Today`.
class ManhuataiUpdateEntry {
  const ManhuataiUpdateEntry({
    required this.comicId,
    required this.comicName,
    required this.comicChapterName,
    required this.updateTime,
    required this.authorName,
    required this.comicType,
    required this.renqi,
    required this.comicFeature,
    required this.chapterFeature,
    required this.featureLocation,
    required this.outterColor,
    required this.innerColor,
    required this.fontSize,
    required this.brushSize,
    required this.featureImg,
    required this.copyrightType,
    required this.score,
    required this.comicNewid,
    this.yesterdayViewNum,
  });

  final int comicId;
  final String comicName;
  final String comicChapterName;
  final String updateTime;
  final String authorName;
  final List<String> comicType;
  final int renqi;
  final String comicFeature;
  final String chapterFeature;
  final int featureLocation;
  final String outterColor;
  final String innerColor;
  final int fontSize;
  final int brushSize;
  final String featureImg;
  final int copyrightType;
  final double score;
  final String comicNewid;

  /// Present on `today` rows only.
  final int? yesterdayViewNum;

  factory ManhuataiUpdateEntry.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiUpdateEntry(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      comicChapterName: ManhuataiJson.asString(source['comic_chapter_name']),
      updateTime: ManhuataiJson.asString(source['update_time']),
      authorName: ManhuataiJson.asString(source['author_name']),
      comicType: ManhuataiJson.asStringList(source['comic_type']),
      renqi: ManhuataiJson.asInt(source['renqi']),
      comicFeature: ManhuataiJson.asString(source['comic_feature']),
      chapterFeature: ManhuataiJson.asString(source['chapter_feature']),
      featureLocation: ManhuataiJson.asInt(source['feature_location']),
      outterColor: ManhuataiJson.asString(source['outter_color']),
      innerColor: ManhuataiJson.asString(source['inner_color']),
      fontSize: ManhuataiJson.asInt(source['font_size']),
      brushSize: ManhuataiJson.asInt(source['brush_size']),
      featureImg: ManhuataiJson.asString(source['feature_img']),
      copyrightType: ManhuataiJson.asInt(source['copyright_type']),
      score: ManhuataiJson.asDouble(source['score']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
      yesterdayViewNum: source.containsKey('yesterday_view_num')
          ? ManhuataiJson.asInt(source['yesterday_view_num'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'comic_chapter_name': comicChapterName,
        'update_time': updateTime,
        'author_name': authorName,
        'comic_type': comicType,
        'renqi': renqi,
        'comic_feature': comicFeature,
        'chapter_feature': chapterFeature,
        'feature_location': featureLocation,
        'outter_color': outterColor,
        'inner_color': innerColor,
        'font_size': fontSize,
        'brush_size': brushSize,
        'feature_img': featureImg,
        'copyright_type': copyrightType,
        'score': score,
        'comic_newid': comicNewid,
        if (yesterdayViewNum != null) 'yesterday_view_num': yesterdayViewNum,
      };
}
