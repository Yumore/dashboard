import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_api.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';

/// Cover/thumbnail backed by `cached_network_image`.
///
/// The URL is resolved through [HakaImageDetail.urlFor] so the selected host
/// (public picacomic by default) decides between the direct and relay URLs.
class HakaNetworkCover extends StatelessWidget {
  const HakaNetworkCover({
    super.key,
    required this.image,
    this.api = HakaApi.picacomic,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 6,
  });

  final HakaImageDetail image;

  final HakaApi api;

  final double? width;

  final double? height;

  final BoxFit fit;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: image.urlFor(api),
        cacheKey: image.cacheKey,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            const ColoredBox(color: Color(0x11000000)),
        errorWidget: (context, url, error) => const ColoredBox(
          color: Color(0x11000000),
          child: Icon(Icons.broken_image_outlined, size: 20),
        ),
      ),
    );
  }
}
