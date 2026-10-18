import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

/// Cover/thumbnail used across the manhuatai screens.
///
/// Uses the host's `cached_network_image` (the source used the same package) and
/// keeps a transparent placeholder so a cover never flashes a grey box.
class ManhuataiCover extends StatelessWidget {
  const ManhuataiCover({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? Image.memory(kTransparentImage, width: width, height: height, fit: fit)
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (_, _) =>
                Image.memory(kTransparentImage, width: width, height: height),
            errorWidget: (_, _, _) => Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, size: 20),
            ),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: image,
    );
  }
}
