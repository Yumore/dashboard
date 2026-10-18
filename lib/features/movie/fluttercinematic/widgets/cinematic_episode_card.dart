import 'package:dashboard/features/movie/fluttercinematic/cinematic_episode.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/episode_card.dart`. The source rendered
/// `episode.title`, `episode.overview`, a 160x90 still and `formatDate(air_date)`.
class CinematicEpisodeCard extends StatelessWidget {
  const CinematicEpisodeCard({required this.episode, super.key});

  final CinematicEpisode episode;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CinematicImage(episode.stillUrl, width: 160, height: 90),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${episode.episodeNumber}. ${episode.title}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    episode.formattedAirDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    episode.overview,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rating: ${episode.voteAverage}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
