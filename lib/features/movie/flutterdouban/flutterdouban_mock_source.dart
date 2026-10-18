import 'package:dashboard/features/movie/flutterdouban/flutterdouban_api.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_category.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_works.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_credits.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_endpoint.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_exception.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_kind.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_list.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_result.dart';

/// The source's `MockRequest` path, ported.
///
/// Faithful to the source:
/// * `subject()` always returns `mock/subject_26266893.json`, whatever id is
///   asked for (`lib/http/API.dart:139-145`);
/// * `subjectComments()` always returns `mock/comments.json`
///   (`lib/http/API.dart:149-154`);
/// * the source had no mock celebrity, works, search or `us_box` path at all,
///   so those are marked as additions below.
///
/// Deliberate deviation: the source's `MockRequest` ignored `start` / `count`
/// and always returned the whole fixture. This port slices the fixture so
/// "load more" terminates; `total` still comes from the fixture.
class FlutterDouBanMockSource implements FlutterDouBanDataSource {
  FlutterDouBanMockSource({FlutterDouBanAssetLoader? loader})
    : _request = FlutterDouBanMockRequest(loader: loader);

  /// The subject the source hard-coded in both `API.getMovieDetail` and
  /// `detail_page.dart:545`.
  static const String subjectFixture = 'subject_26266893';

  /// The short-comment fixture `API.getComments` hard-coded.
  static const String commentsFixture = 'comments';

  /// The long-review fixture `API.REIVIEWS` pointed at.
  static const String reviewsFixture = 'reviews';

  /// Host additions (the source's `Api.searchCelebrity` was network-only).
  static const String celebrityFixture = 'celebrity';
  static const String worksFixture = 'works';

  static const FlutterDouBanSourceKind _kind = FlutterDouBanSourceKind.mock;

  final FlutterDouBanMockRequest _request;

  @override
  Future<FlutterDouBanData<List<FlutterDouBanSubjectRow>>> category(
    FlutterDouBanCategory category,
  ) async {
    switch (category) {
      case FlutterDouBanCategory.inTheaters:
        return _rows(await inTheaters());
      case FlutterDouBanCategory.comingSoon:
        return _rows(await comingSoon());
      case FlutterDouBanCategory.top250:
        return _rows(await top250());
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
          assetPath: data.assetPath,
        );
      case FlutterDouBanCategory.usBox:
        // `usBox()` always throws: the source shipped no `us_box` fixture.
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
          assetPath: data.assetPath,
        );
    }
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> inTheaters({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) => _subjectList(
    FlutterDouBanEndpoint.inTheaters,
    'in_theaters',
    start: start,
    count: count,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> comingSoon({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) => _subjectList(
    FlutterDouBanEndpoint.comingSoon,
    'coming_soon',
    start: start,
    count: count,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectList>> top250({
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) => _subjectList(
    FlutterDouBanEndpoint.top250,
    'top250',
    start: start,
    count: count,
  );

  @override
  Future<FlutterDouBanData<FlutterDouBanWeeklyResult>> weekly() async {
    final json = await _request.mock(FlutterDouBanEndpoint.weekly);
    return _wrap(FlutterDouBanWeeklyResult.fromJson(json), fixture: 'weekly');
  }

  /// The source's `MockRequest` had no `us_box` fixture, so this fails loudly
  /// instead of silently inventing data.
  @override
  Future<FlutterDouBanData<FlutterDouBanUsBoxResult>> usBox() async {
    throw const FlutterDouBanException(
      'Mock 模式没有北美票房榜 fixture（源工程的 MockRequest 也没有 us_box 数据），请切换到网络模式',
    );
  }

  /// Host addition: the source had no mock search. Hits are filtered out of
  /// the two ported list fixtures using douban's real search fields
  /// (`title` / `original_title`).
  @override
  Future<FlutterDouBanData<FlutterDouBanSearchResult>> search(
    String query, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async {
    final needle = query.trim();
    if (needle.isEmpty) throw ArgumentError('搜索关键词不能为空');
    final lower = needle.toLowerCase();
    final pool = <FlutterDouBanSubject>[];
    for (final action in <String>[
      FlutterDouBanEndpoint.top250,
      FlutterDouBanEndpoint.inTheaters,
    ]) {
      pool.addAll(
        FlutterDouBanSubjectList.fromJson(await _request.mock(action)).subjects,
      );
    }
    final seen = <String>{};
    final hits = <FlutterDouBanSubject>[];
    for (final subject in pool) {
      final matches =
          subject.title.toLowerCase().contains(lower) ||
          subject.originalTitle.toLowerCase().contains(lower);
      if (!matches || !seen.add(subject.id)) continue;
      hits.add(subject);
    }
    return _wrapCombined(
      FlutterDouBanSearchResult(
        query: needle,
        start: start,
        count: count,
        total: hits.length,
        subjects: _page(hits, start, count),
      ),
      origin: 'mock/top250+in_theaters',
    );
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanSubjectDetail>> subject(
    String subjectId,
  ) async {
    // Source quirk preserved: the requested id is ignored.
    final json = await _request.mock2(subjectFixture);
    return _wrap(
      FlutterDouBanSubjectDetail.fromJson(json),
      fixture: subjectFixture,
    );
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanCredits>> credits(
    String subjectId,
  ) async {
    // Douban ships credits inside the subject payload; the mock follows.
    final json = await _request.mock2(subjectFixture);
    return _wrap(FlutterDouBanCredits.fromJson(json), fixture: subjectFixture);
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanCommentPage>> subjectComments(
    String subjectId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async {
    // Source quirk preserved: always the 26266893 comment fixture.
    final page = FlutterDouBanCommentPage.fromJson(
      await _request.mock2(commentsFixture),
    );
    final items = _page(page.comments, start, count);
    final hasMore = items.isNotEmpty && start + items.length < page.total;
    return _wrap(
      FlutterDouBanCommentPage(
        start: start,
        count: count,
        total: page.total,
        nextStart: hasMore ? start + count : null,
        comments: items,
        subject: page.subject,
      ),
      fixture: commentsFixture,
    );
  }

  @override
  Future<FlutterDouBanData<FlutterDouBanReviewPage>> subjectReviews(
    String subjectId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async {
    // Source quirk preserved: `API.REIVIEWS` was pinned to 26266893.
    final page = FlutterDouBanReviewPage.fromJson(
      await _request.mock(FlutterDouBanEndpoint.legacyReviews),
    );
    final items = _page(page.reviews, start, count);
    final hasMore = items.isNotEmpty && start + items.length < page.total;
    return _wrap(
      FlutterDouBanReviewPage(
        start: start,
        count: count,
        total: page.total,
        nextStart: hasMore ? start + count : null,
        reviews: items,
        subject: page.subject,
      ),
      fixture: reviewsFixture,
    );
  }

  /// Host addition: the source only fetched celebrities over the network.
  @override
  Future<FlutterDouBanData<FlutterDouBanCelebrity>> celebrity(
    String celebrityId,
  ) async => _wrap(
    FlutterDouBanCelebrity.fromJson(await _request.mock2(celebrityFixture)),
    fixture: celebrityFixture,
  );

  /// Host addition: the source parsed the profile URL as a works payload.
  @override
  Future<FlutterDouBanData<FlutterDouBanCelebrityWorks>> celebrityWorks(
    String celebrityId, {
    int start = 0,
    int count = FlutterDouBanApi.defaultCount,
  }) async {
    final page = FlutterDouBanCelebrityWorks.fromJson(
      await _request.mock2(worksFixture),
    );
    return _wrap(
      FlutterDouBanCelebrityWorks(
        start: start,
        count: count,
        total: page.total,
        celebrity: page.celebrity,
        works: _page(page.works, start, count),
      ),
      fixture: worksFixture,
    );
  }

  @override
  void dispose() {
    // Fixtures are read through rootBundle; nothing to release.
  }

  Future<FlutterDouBanData<FlutterDouBanSubjectList>> _subjectList(
    String action,
    String fixture, {
    required int start,
    required int count,
  }) async {
    final list = FlutterDouBanSubjectList.fromJson(await _request.mock(action));
    return _wrap(
      FlutterDouBanSubjectList(
        title: list.title,
        start: start,
        count: count,
        total: list.total,
        subjects: _page(list.subjects, start, count),
      ),
      fixture: fixture,
    );
  }

  FlutterDouBanData<List<FlutterDouBanSubjectRow>> _rows(
    FlutterDouBanData<FlutterDouBanSubjectList> data,
  ) => FlutterDouBanData<List<FlutterDouBanSubjectRow>>(
    value: data.value.subjects
        .map((subject) => FlutterDouBanSubjectRow(subject: subject))
        .toList(growable: false),
    kind: data.kind,
    origin: data.origin,
    assetPath: data.assetPath,
  );

  FlutterDouBanData<T> _wrap<T>(T value, {required String fixture}) =>
      FlutterDouBanData<T>(
        value: value,
        kind: _kind,
        origin: 'mock/$fixture.json',
        assetPath: FlutterDouBanMockRequest.assetPathFor(fixture),
      );

  /// For the one mock path that reads two fixtures at once (search).
  FlutterDouBanData<T> _wrapCombined<T>(T value, {required String origin}) =>
      FlutterDouBanData<T>(value: value, kind: _kind, origin: origin);

  /// `items[start, start + count)`; an out-of-range start yields an empty page
  /// (the mock fixtures only ever hold the first page).
  List<T> _page<T>(List<T> items, int start, int count) {
    if (start < 0 || count <= 0 || start >= items.length) return <T>[];
    final end = start + count;
    return items.sublist(start, end > items.length ? items.length : end);
  }
}
