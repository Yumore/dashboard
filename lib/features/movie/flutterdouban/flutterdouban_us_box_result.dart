import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_entry.dart';

/// `/v2/movie/us_box` — `{date, subjects: [{rank, box, subject}]}`.
class FlutterDouBanUsBoxResult {
  const FlutterDouBanUsBoxResult({
    this.date = '',
    this.subjects = const <FlutterDouBanUsBoxEntry>[],
  });

  factory FlutterDouBanUsBoxResult.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanUsBoxResult(
        date: FlutterDouBanJson.asString(json['date']).trim(),
        subjects: FlutterDouBanUsBoxEntry.listFrom(json['subjects']),
      );

  final String date;
  final List<FlutterDouBanUsBoxEntry> subjects;

  bool get isEmpty => subjects.isEmpty;
}
