import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Network image work-alike for the source's `Image.network` avatars.
///
/// Kept behind [CachedNetworkImage] so widget tests never fetch remote bytes
/// and the demo always paints a visible placeholder/fallback instead.
class FlutterTiktokRemoteImage extends StatelessWidget {
  const FlutterTiktokRemoteImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: FlutterTiktokPalette.darkGray,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 20,
            color: FlutterTiktokPalette.white66,
          ),
        ),
      ),
    );

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
