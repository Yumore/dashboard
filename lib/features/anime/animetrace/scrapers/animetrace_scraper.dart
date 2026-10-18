import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// A per-site parser.
///
/// Implementations are pure: every method takes an HTML `String` (or a plain
/// URL) and returns domain objects, so each parser is unit testable without a
/// network. Fetching lives in `AnimeTraceRepository`.
abstract class AnimeTraceScraper {
  const AnimeTraceScraper();

  /// Stable id used by `AnimeTraceSource.climbId` (`age`, `yhdm`, `omofun`,
  /// `bangumi`).
  String get climbId;

  /// Display name of the site, e.g. `AGE动漫`.
  String get sourceName;

  /// Base URL used when the user has not configured a custom one.
  String get defaultBaseUrl;

  /// Keyword-search URL for [keyword] on [baseUrl].
  String searchUrl(String baseUrl, String keyword);

  /// Parses a search result page into anime rows that carry at least a name,
  /// a cover URL and a detail URL.
  List<AnimeTraceAnime> parseSearchResults(String html, {String? baseUrl});

  /// Returns a copy of [anime] enriched with the detail page data.
  AnimeTraceAnime applyAnimeInfo(
    String html,
    AnimeTraceAnime anime, {
    String? baseUrl,
  });

  /// Episode page URLs of a series detail page, in broadcast order.
  ///
  /// Sites that do not publish one page per episode return an empty list; the
  /// UI then offers to open the series page in a browser instead of pretending
  /// a stream is available.
  List<String> parseEpisodeUrls(String html, {String? baseUrl}) =>
      const <String>[];

  /// Best-effort stream extraction from an episode/player page.
  ///
  /// Returns `null` when the site does not expose a directly playable stream;
  /// the UI then reports that no playable address was found instead of
  /// pretending playback is available.
  String? parseVideoUrl(
    String html, {
    required int episodeNumber,
    String? baseUrl,
  }) => null;
}
