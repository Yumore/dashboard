import 'package:dashboard/features/movie/flutterdouban/flutterdouban_api.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_category.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_works.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_credits.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_endpoint.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_kind.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_list.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_result.dart';

/// The real douban path (`api.douban.com`), the default in this host.
class FlutterDouBanNetworkSource implements FlutterDouBanDataSource {
  FlutterDouBanNetworkSource({FlutterDouBanApi? api})
    : _api = api ?? FlutterDouBanApi();

  final FlutterDouBanApi _api;

  static const FlutterDouBanSourceKind _kind = FlutterDouBanSourceKind.network;

  FlutterDouBanApi get api => _api;

  @override
  Future<FlutterDouBanData<List<FlutterDouBanSubjectRow>>> category(
    FlutterDouBanCategory category,
  ) async {
    switch (category) {
      case FlutterDouBanCategory.inTheaters:
        final data = await inTheaters();
        return _rows(data);
      case FlutterDouBanCategory.comingSoon:
        final data = await comingSoon();
        return _rows(data);
      case FlutterDouBanCategory.top250:
        final data = await top250();
        return _rows(data);
      case FlutterDouBanCategory.weekly:
        final data = await weekly();
        return FlutterDouBanData<List<FlutterDouBanSubjectRow>>(
          value: [
            for (final entry in data.value.subjects)
              FlutterDouBanSubjectRow(
                subject: entry.subject,
                rank: entry.rank,
                rankDelta: entry.deltaText,
              ),
          ],
          kind: data.kind,
          origin: data.origin,
        );
      case FlutterDouBanCategory.usBox:
        final data = await usBox();
        return FlutterDouBanData<List<FlutterDouBanSubjectRow>>(
          value: [
            for (final entry in data.value.subjects)
              FlutterDouBanSubjectRow(
                subject: entry.subject,
                rank: entry.rank,
                note: entry.boxText,
              ),
          ],
          kind: data.kind,
          origin: data.origin,
        );
    }
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> inTheaters({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.inTheaters(start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> comingSoon({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.comingSoon(start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> top250({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.top250(start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanWeeklyResult>> weekly() async =>
      FlutterDouBanData(
        value: await _api.weekly(),
        kind: _kind,
        origin: FlutterDouBanSourceKind.network.origin,
      );

  @override
  Future<FlutterDouBanData<FlutterDouBanUsBoxResult>> usBox() async =>
      FlutterDouBanData(
        value: await _api.usBox(),
        kind: _kind,
        origin: FlutterDouBanSourceKind.network.origin,
      );

  @override
  Future<FlutterDouBanData<FlutterDouBanSearchResult>> search(
    String query, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.search(query, start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectDetail>> subject(
    String subjectId,
  ) async => FlutterDouBanData(
    value: await _api.subject(subjectId),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanCredits>> credits(
    String subjectId,
  ) async => FlutterDouBanData(
    value: await _api.creditsOf(subjectId),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanCommentPage>> subjectComments(
    String subjectId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.subjectComments(subjectId, start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanReviewPage>> subjectReviews(
    String subjectId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.subjectReviews(subjectId, start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanCelebrity>> celebrity(
    String celebrityId,
  ) async => FlutterDouBanData(
    value: await _api.celebrity(celebrityId),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanCelebrityWorks>> celebrityWorks(
    String celebrityId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async => FlutterDouBanData(
    value: await _api.celebrityWorks(celebrityId, start: start, count: count),
    kind: _kind,
    origin: FlutterDouBanSourceKind.network.origin,
  );

  @override
  void dispose() => _api.dispose();

  /// The endpoint paths this source hits, for the provenance banner.
  static const List<String> endpoints = <String>[
    FlutterDouBanEndpoint.inTheaters,
    FlutterDouBanEndpoint.comingSoon,
    FlutterDouBanEndpoint.top250,
    FlutterDouBanEndpoint.weekly,
    FlutterDouBanEndpoint.usBox,
    FlutterDouBanEndpoint.search,
  ];

  FlutterDouBanData<List<FlutterDouBanSubjectRow>> _rows(
    FlutterDouBanData<FlutterDouBanSubjectList> data,
  ) => FlutterDouBanData<List<FlutterDouBanSubjectRow>>(
    value: data.value.subjects
        .map((subject) => FlutterDouBanSubjectRow(subject: subject))
        .toList(growable: false),
    kind: data.kind,
    origin: data.origin,
  );
}
