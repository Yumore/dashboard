import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';

/// One anime watched on one day, collapsed to the watched episode range.
///
/// The source app builds these from `history` rows: for every distinct
/// `(anime, review_number)` watched on a day it records
/// `min(episode_number)`..`max(episode_number)`.
class AnimeTraceHistoryRecord {
  AnimeTraceHistoryRecord({
    required this.anime,
    this.reviewNumber = 1,
    this.startEpisodeNumber = 0,
    this.endEpisodeNumber = 0,
  });

  AnimeTraceAnime anime;
  int reviewNumber;
  int startEpisodeNumber;
  int endEpisodeNumber;

  /// "第 1 集" or "第 1-3 集".
  String get episodeRangeLabel {
    if (startEpisodeNumber == endEpisodeNumber) {
      return '第 $startEpisodeNumber 集';
    }
    return '第 $startEpisodeNumber-$endEpisodeNumber 集';
  }

  @override
  String toString() =>
      'AnimeTraceHistoryRecord(${anime.animeName}, r$reviewNumber, '
      '$startEpisodeNumber-$endEpisodeNumber)';
}
