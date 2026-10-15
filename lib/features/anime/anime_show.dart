import 'package:dashboard/features/anime/anime_episode.dart';

class AnimeShow {
  const AnimeShow({
    required this.title,
    required this.url,
    this.image,
    this.description = '',
    this.genres = const [],
    this.episodes = const [],
  });

  final String title;
  final Uri url;
  final Uri? image;
  final String description;
  final List<String> genres;
  final List<AnimeEpisode> episodes;
}
