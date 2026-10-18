import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_summary.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_work.dart';

/// `/v2/movie/celebrity/{id}/works` — `{count, start, total, celebrity,
/// works}`.
///
/// Source bug preserved in the port's documentation: `API.searchCelebrityWorks`
/// (`lib/http/API.dart:175-179`) requested `CELEBRITY + id` — the *profile*
/// URL — and then parsed it as `CelebrityWorkCelebrity`. This port calls the
/// real `/works` path; the profile payload already carries `works` inline, so
/// both shapes are supported by [FlutterDouBanCelebrity] and this class.
class FlutterDouBanCelebrityWorks {
  const FlutterDouBanCelebrityWorks({
    this.start = 0,
    this.count = 0,
    this.total = 0,
    this.celebrity,
    this.works = const <FlutterDouBanWork>[],
  });

  factory FlutterDouBanCelebrityWorks.fromJson(Map<String, dynamic> json) {
    final celebrity = FlutterDouBanJson.asMapOrNull(json['celebrity']);
    return FlutterDouBanCelebrityWorks(
      start: FlutterDouBanJson.asInt(json['start']),
      count: FlutterDouBanJson.asInt(json['count']),
      total: FlutterDouBanJson.asInt(json['total']),
      celebrity: celebrity == null
          ? null
          : FlutterDouBanCelebritySummary.fromJson(celebrity),
      works: FlutterDouBanWork.listFrom(json['works']),
    );
  }

  final int start;
  final int count;
  final int total;
  final FlutterDouBanCelebritySummary? celebrity;
  final List<FlutterDouBanWork> works;

  bool get isEmpty => works.isEmpty;

  bool get hasMore => works.isNotEmpty && start + works.length < total;
}
