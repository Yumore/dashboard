import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/movie/movie_episode.dart';
import 'package:dashboard/features/movie/movie_episodes_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({
    required this.movie,
    required this.onFavorite,
    this.loadEpisodes,
    super.key,
  });

  final MovieItem movie;
  final VoidCallback onFavorite;
  final Future<List<MovieEpisode>> Function()? loadEpisodes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        actions: [
          IconButton(
            onPressed: onFavorite,
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: '切换片单收藏',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (movie.poster != null && movie.poster!.hasScheme)
            Image.network(
              movie.poster.toString(),
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.movie_outlined, size: 72),
            ),
          const SizedBox(height: 12),
          Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
          if (movie.category.isNotEmpty) Text(movie.category),
          const SizedBox(height: 12),
          Text(movie.description.isEmpty ? '暂无简介' : movie.description),
          const SizedBox(height: 20),
          if (loadEpisodes != null)
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      MovieEpisodesPage(movie: movie, load: loadEpisodes!),
                ),
              ),
              icon: const Icon(Icons.video_library_outlined),
              label: const Text('选集播放'),
            ),
          if (movie.source != null && movie.source!.hasScheme)
            FilledButton.icon(
              onPressed: () => launchUrl(
                movie.source!,
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('打开播放来源'),
            ),
        ],
      ),
    );
  }
}
