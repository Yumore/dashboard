import 'package:dashboard/features/movie/fluttercinematic/cinematic_search_result.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/search_result_card.dart`: a 120x120
/// `MediumPicture` (poster for movie/tv, avatar for person), title and
/// media-type subtitle, tapping opens the matching detail page.
class CinematicSearchResultCard extends StatelessWidget {
  const CinematicSearchResultCard({
    required this.result,
    required this.onTap,
    super.key,
  });

  final CinematicSearchResult result;
  final ValueChanged<CinematicSearchResult> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            CinematicImage(result.imageUrl, width: 120, height: 120),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    result.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.mediaType} • ${result.subtitle}',
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
