import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// The `{count, start, total, subjects, title}` envelope used by
/// `in_theaters`, `coming_soon` and `top250`.
class FlutterDouBanSubjectList {
  const FlutterDouBanSubjectList({
    this.title = '',
    this.start = 0,
    this.count = 0,
    this.total = 0,
    this.subjects = const <FlutterDouBanSubject>[],
  });

  factory FlutterDouBanSubjectList.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanSubjectList(
        title: FlutterDouBanJson.asString(json['title']).trim(),
        start: FlutterDouBanJson.asInt(json['start']),
        count: FlutterDouBanJson.asInt(json['count']),
        total: FlutterDouBanJson.asInt(json['total']),
        subjects: FlutterDouBanSubject.listFrom(json['subjects']),
      );

  final String title;
  final int start;
  final int count;
  final int total;
  final List<FlutterDouBanSubject> subjects;

  bool get isEmpty => subjects.isEmpty;

  /// Douban's `count` is the requested page size; the payload length is the
  /// truth for "how many we actually got".
  bool get hasMore => subjects.isNotEmpty && start + subjects.length < total;
}
