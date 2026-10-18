import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/poster.dart` and `season_card.dart`.
/// One widget covers both because they differed only in the title rule, which
/// [CinematicTvSeason.getFormattedTitle] already encodes.
class CinematicPosterCard extends StatelessWidget {
  const CinematicPosterCard({
    required this.title,
    required this.posterUrl,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    this.badge,
    super.key,
  });

  CinematicPosterCard.media({
    required CinematicMediaItem item,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    super.key,
  }) : title = item.title,
       posterUrl = item.getPosterUrl(),
       badge = '${item.getReleaseYear()}';

  CinematicPosterCard.season({
    required CinematicTvSeason season,
    required this.onTap,
    this.width = 130,
    this.height = 195,
    super.key,
  }) : title = season.name,
       posterUrl = season.getPosterUrl(),
       badge = season.getReleaseYear();

  final String title;
  final String posterUrl;
  final VoidCallback onTap;
  final double width;
  final double height;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        // The rails that host this card give it a fixed height (e.g. 250 in the
        // similar-seasons row) that can be shorter than poster + two lines of
        // title, so the content is allowed to overflow rather than throw.
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            // The card is dropped into fixed-height rows (episode/cast rails),
            // so it must not stretch to the parent's height.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CinematicImage(posterUrl, width: width, height: height),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (badge != null && badge!.isNotEmpty)
                Text(badge!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
