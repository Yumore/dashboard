import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';

/// `rating` on a subject: `{max, average, stars, min, details?}`.
///
/// `details` is absent on real `top250` rows, so it defaults to an empty map.
class FlutterDouBanRating {
  const FlutterDouBanRating({
    this.max = 10,
    this.average = 0,
    this.min = 0,
    this.stars = '',
    this.details = const <int, double>{},
  });

  factory FlutterDouBanRating.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FlutterDouBanRating();
    return FlutterDouBanRating(
      max: FlutterDouBanJson.asInt(json['max']),
      average: FlutterDouBanJson.asDouble(json['average']),
      min: FlutterDouBanJson.asInt(json['min']),
      stars: FlutterDouBanJson.asString(json['stars']),
      details: FlutterDouBanJson.asScoreDetails(json['details']),
    );
  }

  final int max;
  final double average;
  final int min;
  final String stars;
  final Map<int, double> details;

  bool get isEmpty => average == 0 && stars.isEmpty && details.isEmpty;

  /// Rating buckets are counts; used for the score-distribution bar.
  int get ratingCount =>
      details.values.fold<double>(0, (sum, item) => sum + item).round();

  bool isRated(double star) => details.containsKey(star.round());
}
