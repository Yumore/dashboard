import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// Pure core of the "fix lapsed covers" flow.
///
/// The source app checked every network cover URL for reachability and then
/// re-scraped the anime info for the dead ones, five at a time. Selection and
/// batching are pure; the probing/scraping is injected by the caller.
class AnimeTraceLapseCoverFix {
  const AnimeTraceLapseCoverFix._();

  /// Repair batch size used by the source app (`limit = 5`).
  static const int repairBatchSize = 5;

  /// Anime whose cover is a network URL and therefore can lapse. Local file
  /// covers are skipped: they cannot fail because the site went away.
  static List<AnimeTraceAnime> candidates(List<AnimeTraceAnime> animes) {
    return <AnimeTraceAnime>[
      for (final anime in animes)
        if (anime.animeCoverUrl.startsWith('http')) anime,
    ];
  }

  /// Of [candidates], the ones whose cover URL is reported unreachable by
  /// [reachability] (a URL -> bool map, so the check itself stays injectable).
  static List<AnimeTraceAnime> lapsedByReachability(
    List<AnimeTraceAnime> animes,
    Map<String, bool> reachability,
  ) {
    return <AnimeTraceAnime>[
      for (final anime in candidates(animes))
        if (reachability[anime.animeCoverUrl] != true) anime,
    ];
  }

  /// Same as [lapsedByReachability] but awaits [reachable] for each URL
  /// concurrently (the source app fired all checks at once).
  static Future<List<AnimeTraceAnime>> detectLapsed(
    List<AnimeTraceAnime> animes, {
    required Future<bool> Function(String url) reachable,
  }) async {
    final candidatesList = candidates(animes);
    if (candidatesList.isEmpty) return <AnimeTraceAnime>[];
    final results = await Future.wait<bool>(
      candidatesList.map((anime) => reachable(anime.animeCoverUrl)),
    );
    final lapsed = <AnimeTraceAnime>[];
    for (var index = 0; index < candidatesList.length; index++) {
      if (!results[index]) lapsed.add(candidatesList[index]);
    }
    return lapsed;
  }

  /// Splits [animes] into repair batches of at most [size].
  static List<List<AnimeTraceAnime>> batches(
    List<AnimeTraceAnime> animes, {
    int size = repairBatchSize,
  }) {
    if (size <= 0) throw ArgumentError.value(size, 'size', 'must be > 0');
    final result = <List<AnimeTraceAnime>>[];
    for (var start = 0; start < animes.length; start += size) {
      final end = start + size > animes.length ? animes.length : start + size;
      result.add(animes.sublist(start, end));
    }
    return result;
  }
}
