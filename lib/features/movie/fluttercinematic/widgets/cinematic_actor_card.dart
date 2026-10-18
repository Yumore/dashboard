import 'package:dashboard/features/movie/fluttercinematic/cinematic_actor.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/widgets/actor_card.dart`: circular 56x56 avatar
/// (the source used `w200` for the person list and `w300` elsewhere; this port
/// uses the module's single medium size, `w300`), name and character.
class CinematicActorCard extends StatelessWidget {
  const CinematicActorCard({
    required this.actor,
    required this.onTap,
    this.width = 110,
    super.key,
  });

  final CinematicActor actor;
  final ValueChanged<CinematicActor> onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(actor),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CinematicImage(
              actor.profilePictureUrl,
              width: 56,
              height: 56,
              shape: BoxShape.circle,
            ),
            const SizedBox(height: 6),
            Text(
              actor.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              actor.character,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
