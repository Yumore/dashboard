import 'package:dashboard/features/movie/fluttercinematic/cinematic_genres.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/media_list_item.dart`: a stacked card with
/// the backdrop on top, then the title, `getReleaseYear()` and genre labels.
/// `onTap` receives the item so pages can push the detail route.
class CinematicMediaListItem extends StatelessWidget {
  const CinematicMediaListItem({
    required this.item,
    required this.onTap,
    this.favoriteButton,
    super.key,
  });

  final CinematicMediaItem item;
  final ValueChanged<CinematicMediaItem> onTap;

  /// Optional trailing favourite control, supplied by pages that own a
  /// [CinematicFavoritesStore].
  final Widget? favoriteButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(item),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                CinematicImage(
                  item.getBackDropUrl(),
                  height: 210,
                  width: double.infinity,
                ),
                ?favoriteButton,
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${item.getReleaseYear()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                CinematicGenres.label(item.genreIds),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
