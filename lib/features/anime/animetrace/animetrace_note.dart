import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_note_image.dart';

/// An episode note (or the series' score note when [episode] is episode 0).
///
/// The source app persists notes as rows of `episode_note` plus any number of
/// `image` rows, and stores images as paths relative to the user's configured
/// note-image folder.
class AnimeTraceNote {
  AnimeTraceNote({
    this.id = 0,
    required this.anime,
    this.episode,
    this.noteContent = '',
    List<AnimeTraceNoteImage>? relativeLocalImages,
    List<String>? imgUrls,
    this.createTime = '',
    this.updateTime = '',
  }) : relativeLocalImages = relativeLocalImages ?? <AnimeTraceNoteImage>[],
       imgUrls = imgUrls ?? <String>[];

  int id;
  AnimeTraceAnime anime;
  AnimeTraceEpisode? episode;
  String noteContent;

  /// Images copied into the user's local note-image folder.
  final List<AnimeTraceNoteImage> relativeLocalImages;

  /// Remote images pasted as markdown by the user.
  final List<String> imgUrls;

  String createTime;
  String updateTime;

  /// A note attached to episode 0 is the series rating/review note.
  bool get isRateNote => episode == null || episode!.isRateEpisode;

  int get episodeNumber => episode?.number ?? 0;

  static AnimeTraceNote createRateNote(AnimeTraceAnime anime) {
    return AnimeTraceNote(anime: anime, episode: AnimeTraceEpisode(0));
  }

  static AnimeTraceNote createEpisodeNote(
    AnimeTraceAnime anime,
    AnimeTraceEpisode episode,
  ) {
    return AnimeTraceNote(anime: anime, episode: episode);
  }

  @override
  String toString() =>
      'AnimeTraceNote(id=$id, anime=${anime.animeName}, '
      'episode=$episodeNumber, chars=${noteContent.length}, '
      'images=${relativeLocalImages.length})';
}
