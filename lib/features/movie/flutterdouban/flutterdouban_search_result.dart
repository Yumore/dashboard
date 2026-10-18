import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// `/v2/movie/search` — same envelope as the list endpoints plus the echoed
/// `query`.
///
/// The source's `SearchResultEntity` stored `subjects` and the source's search
/// page sorted them by `year` descending before rendering.
class FlutterDouBanSearchResult {
  const FlutterDouBanSearchResult({
    this.query = '',
    this.start = 0,
    this.count = 0,
    this.total = 0,
    this.subjects = const <FlutterDouBanSubject>[],
  });

  factory FlutterDouBanSearchResult.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanSearchResult(
        query: FlutterDouBanJson.asString(json['query'] ?? json['q']).trim(),
        start: FlutterDouBanJson.asInt(json['start']),
        count: FlutterDouBanJson.asInt(json['count']),
        total: FlutterDouBanJson.asInt(json['total']),
        subjects: FlutterDouBanSubject.listFrom(json['subjects']),
      );

  final String query;
  final int start;
  final int count;
  final int total;
  final List<FlutterDouBanSubject> subjects;

  bool get isEmpty => subjects.isEmpty;

  bool get hasMore => subjects.isNotEmpty && start + subjects.length < total;

  /// The source sorted hits newest-first (`search_page.dart:36`).
  List<FlutterDouBanSubject> get sortedByYear {
    final sorted = <FlutterDouBanSubject>[...subjects];
    sorted.sort((a, b) => b.year.compareTo(a.year));
    return sorted;
  }
}
