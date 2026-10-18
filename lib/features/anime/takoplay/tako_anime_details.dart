import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_genre.dart';

/// Everything a Tako-Play (gogoanime.wiki) anime detail page exposes, plus the
/// episode list fetched from the `load-list-episode` AJAX endpoint.
class TakoAnimeDetails {
  const TakoAnimeDetails({
    required this.title,
    required this.url,
    this.image,
    this.summary = '',
    this.status = '',
    this.releasedDate = '',
    this.genres = const [],
    this.episodeId = '',
    this.episodes = const [],
  });

  final String title;
  final Uri url;
  final Uri? image;
  final String summary;
  final String status;
  final String releasedDate;
  final List<TakoGenre> genres;

  /// `anime_id` read from the detail page; drives the episode list request.
  final String episodeId;

  /// Episodes in ascending order (the endpoint returns them newest first).
  final List<TakoEpisode> episodes;
}
