/// The douban v2 movie endpoints the source app really calls.
///
/// Ported from `lib/http/API.dart:20-37`. Two source quirks are preserved
/// deliberately:
/// * `IN_THEATERS` / `COMING_SOON` / `WEEKLY` embedded `?apikey=...` inside the
///   path string, so `MockRequest`'s action→fixture map keyed on those strings.
///   Here the path and the key are separate constants and the key is added as a
///   query parameter; [FlutterDouBanMockRequest] keeps the source mapping.
/// * `REIVIEWS` (sic) was hard-coded to subject `26266893`; the per-subject
///   builder below replaces it while [FlutterDouBanEndpoint.legacyReviews]
///   records the literal constant.
class FlutterDouBanEndpoint {
  const FlutterDouBanEndpoint._();

  static const String baseUrl = 'https://api.douban.com';

  /// Public API key verified in the source at `lib/http/API.dart:26`.
  static const String apiKey = '0b2bdeda43b5688921839c8ecb20399b';

  static const String top250 = '/v2/movie/top250';
  static const String inTheaters = '/v2/movie/in_theaters';
  static const String comingSoon = '/v2/movie/coming_soon';
  static const String weekly = '/v2/movie/weekly';

  /// Real douban v2 endpoint (the source never called it, but the port covers
  /// the north-american box office list).
  static const String usBox = '/v2/movie/us_box';

  static const String search = '/v2/movie/search';
  static const String celebrityPrefix = '/v2/movie/celebrity/';
  static const String subjectPrefix = '/v2/movie/subject/';

  /// `API.REIVIEWS` verbatim from the source (`lib/http/API.dart:37`).
  static const String legacyReviews = '/v2/movie/subject/26266893/reviews';

  static String subject(String subjectId) => '$subjectPrefix$subjectId';
  static String subjectComments(String subjectId) =>
      '${subject(subjectId)}/comments';
  static String subjectReviews(String subjectId) =>
      '${subject(subjectId)}/reviews';
  static String celebrity(String celebrityId) => '$celebrityPrefix$celebrityId';
  static String celebrityWorks(String celebrityId) =>
      '${celebrity(celebrityId)}/works';
}
