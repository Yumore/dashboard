import 'package:dashboard/features/movie/flutterdouban/flutterdouban_author.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_score.dart';

/// A long review (`/v2/movie/subject/{id}/reviews`).
///
/// The source's `MovieLongCommentsEntity` read `title`, `summary`, `content`,
/// `useful_count`, `useless_count`, `comments_count`, `share_url`, `alt`,
/// `created_at` and `updated_at`; all of them are kept here.
class FlutterDouBanReview {
  const FlutterDouBanReview({
    this.id = '',
    this.subjectId = '',
    this.title = '',
    this.summary = '',
    this.content = '',
    this.usefulCount = 0,
    this.uselessCount = 0,
    this.commentsCount = 0,
    this.rating = const FlutterDouBanScore(),
    this.author = const FlutterDouBanAuthor(),
    this.createdAt = '',
    this.updatedAt = '',
    this.shareUrl = '',
    this.alt = '',
  });

  factory FlutterDouBanReview.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanReview(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        subjectId: FlutterDouBanJson.asString(json['subject_id']).trim(),
        title: FlutterDouBanJson.asString(json['title']).trim(),
        summary: FlutterDouBanJson.asString(json['summary']).trim(),
        content: FlutterDouBanJson.asString(json['content']).trim(),
        usefulCount: FlutterDouBanJson.asInt(json['useful_count']),
        uselessCount: FlutterDouBanJson.asInt(json['useless_count']),
        commentsCount: FlutterDouBanJson.asInt(json['comments_count']),
        rating: FlutterDouBanScore.fromJson(
          FlutterDouBanJson.asMapOrNull(json['rating']),
        ),
        author: FlutterDouBanAuthor.fromJson(
          FlutterDouBanJson.asMapOrNull(json['author']),
        ),
        createdAt: FlutterDouBanJson.asString(json['created_at']).trim(),
        updatedAt: FlutterDouBanJson.asString(json['updated_at']).trim(),
        shareUrl: FlutterDouBanJson.asString(json['share_url']).trim(),
        alt: FlutterDouBanJson.asString(json['alt']).trim(),
      );

  static List<FlutterDouBanReview> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanReview.fromJson).toList(growable: false);

  final String id;
  final String subjectId;
  final String title;
  final String summary;
  final String content;
  final int usefulCount;
  final int uselessCount;
  final int commentsCount;
  final FlutterDouBanScore rating;
  final FlutterDouBanAuthor author;
  final String createdAt;
  final String updatedAt;
  final String shareUrl;
  final String alt;

  /// Douban truncates `summary` with a trailing ellipsis; fall back to the
  /// body when a payload omits it.
  String get displaySummary =>
      summary.isNotEmpty ? summary : content.split('\n').first.trim();

  String get usefulText {
    if (usefulCount < 1000) return '$usefulCount';
    return '${(usefulCount / 1000).toStringAsFixed(1)}k';
  }
}
