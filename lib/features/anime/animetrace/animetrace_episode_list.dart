import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';

/// Builds the episode rows of a series detail page.
///
/// A pure function over the collected anime plus its raw
/// `episode_number -> watch date` map, so the detail page never has to guess
/// how many rows to draw.
class AnimeTraceEpisodeList {
  const AnimeTraceEpisodeList._();

  /// Episode `0` (the rating note) is never part of the list.
  static List<AnimeTraceEpisode> build(
    AnimeTraceAnime anime,
    Map<int, String> watchedDates, {
    int reviewNumber = 1,
  }) {
    var count = anime.animeEpisodeCnt > 0 ? anime.animeEpisodeCnt : 0;

    // Watched rows can exceed a stale episode count: keep them visible.
    for (final rawNumber in watchedDates.keys) {
      if (rawNumber > count) count = rawNumber;
    }
    if (count <= 0) return <AnimeTraceEpisode>[];

    return <AnimeTraceEpisode>[
      for (var number = 1; number <= count; number++)
        AnimeTraceEpisode(
          number,
          reviewNumber: reviewNumber,
          startNumber: anime.episodeStartNumber,
          dateTime: watchedDates[number],
        ),
    ];
  }
}
