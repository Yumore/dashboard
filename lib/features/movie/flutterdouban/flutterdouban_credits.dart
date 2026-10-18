import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_summary.dart';

/// Cast + director lists for one subject.
///
/// Douban's v2 API has no standalone credits endpoint — `casts` and `directors`
/// ship inside the subject payload — so [FlutterDouBanApi.creditsOf] calls the
/// subject endpoint and maps these two lists out of it. The source rendered
/// them from `MovieDetailBean.casts` / `.directors` the same way.
class FlutterDouBanCredits {
  const FlutterDouBanCredits({
    this.casts = const <FlutterDouBanCelebritySummary>[],
    this.directors = const <FlutterDouBanCelebritySummary>[],
  });

  factory FlutterDouBanCredits.fromJson(Map<String, dynamic> json) =>
      FlutterDouBanCredits(
        casts: FlutterDouBanCelebritySummary.listFrom(json['casts']),
        directors: FlutterDouBanCelebritySummary.listFrom(json['directors']),
      );

  final List<FlutterDouBanCelebritySummary> casts;
  final List<FlutterDouBanCelebritySummary> directors;

  bool get isEmpty => casts.isEmpty && directors.isEmpty;

  /// Directors first, then cast — the source's `sliverCasts` order.
  List<FlutterDouBanCelebritySummary> get all =>
      <FlutterDouBanCelebritySummary>[...directors, ...casts];
}
