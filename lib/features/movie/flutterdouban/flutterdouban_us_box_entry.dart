import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';

/// One row of `/v2/movie/us_box`: `{rank, box, subject}`.
///
/// The north-american box office response wraps each subject with the week's
/// gross in `box` (in USD).
class FlutterDouBanUsBoxEntry {
  const FlutterDouBanUsBoxEntry({
    this.rank = 0,
    this.box = 0,
    required this.subject,
  });

  factory FlutterDouBanUsBoxEntry.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanUsBoxEntry(
        rank: FlutterDouBanJson.asInt(json['rank']),
        box: FlutterDouBanJson.asInt(json['box']),
        subject: FlutterDouBanSubject.fromJson(
          FlutterDouBanJson.asMap(json['subject']),
        ),
      );

  static List<FlutterDouBanUsBoxEntry> listFrom(Object? value) =>
      FlutterDouBanJson.asMapList(
        value,
      ).map(FlutterDouBanUsBoxEntry.fromJson).toList(growable: false);

  final int rank;
  final int box;
  final FlutterDouBanSubject subject;

  /// `$12,345,678` — grouping matches what douban's own site prints.
  String get boxText {
    final digits = box.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return '\$$buffer';
  }
}
