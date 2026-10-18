import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders one of the demo's hard-coded sample image URLs.
///
/// The source uses `CachedNetworkImage` for avatars and hero skins; the port
/// keeps the same URLs and always supplies a bundled fallback, so the static
/// demo still renders when the device is offline.
class FlutterWechatFullRemoteImage extends StatelessWidget {
  const FlutterWechatFullRemoteImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback = 'assets/flutterwechatfull_demo/DefaultHead_48x48.png',
    this.borderRadius,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallback;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _fallback(),
      errorWidget: (context, url, error) => _fallback(),
    );
    if (borderRadius == null) {
      return image;
    }
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _fallback() {
    return Image.asset(
      fallback,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE0E0E0),
      ),
    );
  }
}
