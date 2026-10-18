import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// `/v2/movie/subject/{id}/reviews` envelope (`start`, `count`, `total`,
/// `next_start`, `reviews`, `subject`).
class FlutterDouBanReviewPage {
  const FlutterDouBanReviewPage({
    this.start = 0,
    this.count = 0,
    this.total = 0,
    this.nextStart,
    this.reviews = const <FlutterDouBanReview>[],
    this.subject,
  });

  factory FlutterDouBanReviewPage.fromJson(Map<String, dynamic> json) {
    final subject = FlutterDouBanJson.asMapOrNull(json['subject']);
    return FlutterDouBanReviewPage(
      start: FlutterDouBanJson.asInt(json['start']),
      count: FlutterDouBanJson.asInt(json['count']),
      total: FlutterDouBanJson.asInt(json['total']),
      nextStart: FlutterDouBanJson.asNullableInt(json['next_start']),
      reviews: FlutterDouBanReview.listFrom(json['reviews']),
      subject: subject == null ? null : FlutterDouBanSubject.fromJson(subject),
    );
  }

  final int start;
  final int count;
  final int total;
  final int? nextStart;
  final List<FlutterDouBanReview> reviews;
  final FlutterDouBanSubject? subject;

  bool get isEmpty => reviews.isEmpty;

  bool get hasMore {
    final next = nextStart;
    return reviews.isNotEmpty && next != null && next > start;
  }
}
