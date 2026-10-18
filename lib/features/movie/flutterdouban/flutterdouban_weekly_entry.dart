import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// One row of `/v2/movie/weekly`: `{subject, rank, delta}`.
class FlutterDouBanWeeklyEntry {
  const FlutterDouBanWeeklyEntry({
    this.rank = 0,
    this.delta = 0,
    required this.subject,
  });

  factory FlutterDouBanWeeklyEntry.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanWeeklyEntry(
        rank: FlutterDouBanJson.asInt(json['rank']),
        delta: FlutterDouBanJson.asInt(json['delta']),
        subject: FlutterDouBanSubject.fromJson(
          FlutterDouBanJson.asMap(json['subject']),
        ),
      );

  static List<FlutterDouBanWeeklyEntry> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanWeeklyEntry.fromJson).toList(growable: false);

  final int rank;
  final int delta;
  final FlutterDouBanSubject subject;

  /// `↑10` / `↓3` / `—`, as shown next to the rank.
  String get deltaText {
    if (delta == 0) return '—';
    return delta > 0 ? '↑$delta' : '↓${-delta}';
  }
}
