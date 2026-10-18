import 'package:dashboard/features/movie/flutterdouban/flutterdouban_author.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_score.dart';

/// A short comment (`/v2/movie/subject/{id}/comments`).
///
/// Field names are the douban ones: `subject_id`, `useful_count`,
/// `created_at`, `rating.value`.
class FlutterDouBanComment {
  const FlutterDouBanComment({
    this.id = '',
    this.subjectId = '',
    this.content = '',
    this.usefulCount = 0,
    this.rating = const FlutterDouBanScore(),
    this.author = const FlutterDouBanAuthor(),
    this.createdAt = '',
  });

  factory FlutterDouBanComment.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanComment(
        id: FlutterDouBanJson.asString(json['id']).trim(),
        subjectId: FlutterDouBanJson.asString(json['subject_id']).trim(),
        content: FlutterDouBanJson.asString(json['content']).trim(),
        usefulCount: FlutterDouBanJson.asInt(json['useful_count']),
        rating: FlutterDouBanScore.fromJson(
          FlutterDouBanJson.asMapOrNull(json['rating']),
        ),
        author: FlutterDouBanAuthor.fromJson(
          FlutterDouBanJson.asMapOrNull(json['author']),
        ),
        createdAt: FlutterDouBanJson.asString(json['created_at']).trim(),
      );

  static List<FlutterDouBanComment> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanComment.fromJson).toList(growable: false);

  final String id;
  final String subjectId;
  final String content;
  final int usefulCount;
  final FlutterDouBanScore rating;
  final FlutterDouBanAuthor author;
  final String createdAt;

  /// The source's `getUsefulCount` (`lib/pages/detail/detail_page.dart:504`):
  /// `34123` → `34.1k`.
  String get usefulText {
    if (usefulCount < 1000) return '$usefulCount';
    return '${(usefulCount / 1000).toStringAsFixed(1)}k';
  }
}
