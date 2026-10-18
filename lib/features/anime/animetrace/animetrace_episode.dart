import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_note.dart';

/// One episode row of a series detail page.
///
/// [number] is the raw, source-relative episode number; episode `0` is the
/// reserved "rating note" episode used by the source app's score notes. The
/// number shown to the user is [numberWithStartNumber].
class AnimeTraceEpisode {
  AnimeTraceEpisode(
    this.number, {
    this.reviewNumber = 1,
    this.startNumber = 1,
    this.dateTime,
    this.note,
    this.noteLoaded = false,
    this.descTitle = '',
    this.hideDefaultDesc = false,
  });

  final int number;

  /// Rewatch counter; `(anime, number, reviewNumber)` identifies a history row
  /// and its episode note.
  final int reviewNumber;

  /// The series' `episodeStartNumber`, so a series starting at episode 7 shows
  /// "第 7 集" for its first row.
  final int startNumber;

  /// Watch time; `null` means "not watched yet".
  String? dateTime;

  /// Lazily attached note. `null` while [noteLoaded] is false.
  AnimeTraceNote? note;
  bool noteLoaded;

  /// Optional per-episode description title scraped from the source.
  final String descTitle;

  /// When true the default "第 N 集" caption is replaced by [descTitle].
  final bool hideDefaultDesc;

  /// Episode `0` is the score note, not a real episode.
  bool get isRateEpisode => number == 0;

  int get numberWithStartNumber => number + startNumber - 1;

  bool isChecked() => dateTime != null;

  String get caption {
    final base = '第 $numberWithStartNumber 集';
    if (descTitle.isEmpty) return base;
    return hideDefaultDesc ? descTitle : '$base $descTitle';
  }

  @override
  String toString() => 'AnimeTraceEpisode($number, watched=${isChecked()})';

  /// The number the user sees for the raw, database-stored [rawNumber] of
  /// [anime] (the source app's `EpisodeUtil.getFixedEpisodeNumber`).
  static int fixedEpisodeNumber(AnimeTraceAnime anime, int rawNumber) {
    if (anime.calEpisodeNumberFromOne) return rawNumber;
    if (rawNumber == 0) return 0;
    return anime.episodeStartNumber + rawNumber - 1;
  }

  /// The first raw episode number a series counts from.
  static int fakeStartNumber(AnimeTraceAnime anime) =>
      anime.calEpisodeNumberFromOne ? 1 : anime.episodeStartNumber;
}
