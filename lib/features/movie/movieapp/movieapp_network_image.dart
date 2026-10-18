import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// TMDb image loader that falls back to a placeholder when the path is absent
/// (TMDb `poster_path` / `backdrop_path` / `profile_path` can be null).
class MovieAppNetworkImage extends StatelessWidget {
  const MovieAppNetworkImage(this.url, {this.fit = BoxFit.cover, super.key});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final value = url;
    if (value == null) return const _Placeholder();
    return CachedNetworkImage(
      imageUrl: value,
      fit: fit,
      placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, _, _) => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFF212121),
    child: Center(child: Icon(Icons.movie_outlined, color: Colors.white54)),
  );
}
