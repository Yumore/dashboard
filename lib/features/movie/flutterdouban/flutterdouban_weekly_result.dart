import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_entry.dart';

/// `/v2/movie/weekly` — `{title, subjects: [{subject, rank, delta}]}`.
///
/// The source parsed these rows into `SubjectEntity` (`Subject` + `rank` +
/// `delta`) via `API.getWeekly`.
class FlutterDouBanWeeklyResult {
  const FlutterDouBanWeeklyResult({
    this.title = '',
    this.subjects = const <FlutterDouBanWeeklyEntry>[],
  });

  factory FlutterDouBanWeeklyResult.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanWeeklyResult(
        title: FlutterDouBanJson.asString(json['title']).trim(),
        subjects: FlutterDouBanWeeklyEntry.listFrom(json['subjects']),
      );

  final String title;
  final List<FlutterDouBanWeeklyEntry> subjects;

  bool get isEmpty => subjects.isEmpty;
}
