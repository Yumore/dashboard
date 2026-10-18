import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// The three resolution variants of one chapter page URL.
///
/// The `$$` in these templates is the page-number placeholder substituted by
/// `ManhuataiImageUrl.chapterPageUrl`.
///
/// Source: `lib/models/comic_info_body.dart` → `Chapter_image`.
class ManhuataiChapterImage {
  const ManhuataiChapterImage({
    required this.low,
    required this.middle,
    required this.high,
  });

  final String low;
  final String middle;
  final String high;

  static const ManhuataiChapterImage empty =
      ManhuataiChapterImage(low: '', middle: '', high: '');

  factory ManhuataiChapterImage.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiChapterImage(
      low: ManhuataiJson.asString(source['low']),
      middle: ManhuataiJson.asString(source['middle']),
      high: ManhuataiJson.asString(source['high']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'low': low,
        'middle': middle,
        'high': high,
      };
}
