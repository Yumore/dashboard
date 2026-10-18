import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// `/v2/movie/subject/{id}/comments` envelope.
///
/// Douban reports the cursor as `next_start`, which the source's
/// `CommentsEntity` kept as `nextStart`.
class FlutterDouBanCommentPage {
  const FlutterDouBanCommentPage({
    this.start = 0,
    this.count = 0,
    this.total = 0,
    this.nextStart,
    this.comments = const <FlutterDouBanComment>[],
    this.subject,
  });

  factory FlutterDouBanCommentPage.fromJson(Map<String, dynamic> json) {
    final subject = FlutterDouBanJson.asMapOrNull(json['subject']);
    return FlutterDouBanCommentPage(
      start: FlutterDouBanJson.asInt(json['start']),
      count: FlutterDouBanJson.asInt(json['count']),
      total: FlutterDouBanJson.asInt(json['total']),
      nextStart: FlutterDouBanJson.asNullableInt(json['next_start']),
      comments: FlutterDouBanComment.listFrom(json['comments']),
      subject: subject == null ? null : FlutterDouBanSubject.fromJson(subject),
    );
  }

  final int start;
  final int count;
  final int total;
  final int? nextStart;
  final List<FlutterDouBanComment> comments;
  final FlutterDouBanSubject? subject;

  bool get isEmpty => comments.isEmpty;

  bool get hasMore {
    final next = nextStart;
    return comments.isNotEmpty && next != null && next > start;
  }
}
