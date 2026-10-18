import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// The 5-point `rating` attached to reviews and short comments:
/// `{max: 5, value: 1.0, min: 0}` (may be absent when the author skipped it).
class FlutterDouBanScore {
  const FlutterDouBanScore({this.max = 5, this.value = 0, this.min = 0});

  factory FlutterDouBanScore.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FlutterDouBanScore();
    return FlutterDouBanScore(
      max: FlutterDouBanJson.asInt(json['max']),
      value: FlutterDouBanJson.asDouble(json['value']),
      min: FlutterDouBanJson.asInt(json['min']),
    );
  }

  final int max;
  final double value;
  final int min;

  bool get isEmpty => value == 0;
}
