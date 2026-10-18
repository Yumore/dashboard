import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Replaces the source `FadeInImage.assetNetwork(..., placeholder:
/// 'assets/placeholder.jpg')` calls: the host has no `assets/placeholder.jpg`
/// and this module may not add assets (write scope forbids editing pubspec and
/// adding asset files), so an icon placeholder is drawn instead.
class CinematicImage extends StatelessWidget {
  const CinematicImage(
    this.url, {
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final value = url;
    final radius = shape == BoxShape.circle
        ? BorderRadius.circular((width ?? 56) / 2)
        : BorderRadius.zero;
    if (value == null || value.isEmpty) {
      return _fallback(radius);
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: value,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => _loading(),
        errorWidget: (_, _, _) => _fallback(radius),
      ),
    );
  }

  Widget _loading() => SizedBox(
    width: width,
    height: height,
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  Widget _fallback(BorderRadius radius) => ClipRRect(
    borderRadius: radius,
    child: Container(
      width: width,
      height: height,
      color: const Color(0xFF212121),
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.white54),
      ),
    ),
  );
}
