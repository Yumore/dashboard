import 'package:dashboard/features/movie/flutterdouban/flutterdouban_category.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_works.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_credits.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_list.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_us_box_result.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_weekly_result.dart';

/// The one interface both the real client and the fixture reader implement.
///
/// The source's `useNetData` flag chose between `HttpRequest` and `MockRequest`
/// at runtime (`lib/repository/movie_repository.dart:44-49`); here the same
/// choice produces two implementations of this interface, and every returned
/// value is wrapped in [FlutterDouBanData] so the provenance travels with it.
abstract class FlutterDouBanDataSource {
  /// One browse tab's worth of rows, ranked where the endpoint ranks.
  Future<FlutterDouBanData<List<FlutterDouBanSubjectRow>>> category(
    FlutterDouBanCategory category,
  );

  Future<FlutterDouBanData<FlutterDouBanSubjectList>> inTheaters({
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanSubjectList>> comingSoon({
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanSubjectList>> top250({
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanWeeklyResult>> weekly();

  Future<FlutterDouBanData<FlutterDouBanUsBoxResult>> usBox();

  Future<FlutterDouBanData<FlutterDouBanSearchResult>> search(
    String query, {
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanSubjectDetail>> subject(
    String subjectId,
  );

  Future<FlutterDouBanData<FlutterDouBanCredits>> credits(String subjectId);

  Future<FlutterDouBanData<FlutterDouBanCommentPage>> subjectComments(
    String subjectId, {
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanReviewPage>> subjectReviews(
    String subjectId, {
    int start,
    int count,
  });

  Future<FlutterDouBanData<FlutterDouBanCelebrity>> celebrity(
    String celebrityId,
  );

  Future<FlutterDouBanData<FlutterDouBanCelebrityWorks>> celebrityWorks(
    String celebrityId, {
    int start,
    int count,
  });

  void dispose();
}
