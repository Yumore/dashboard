import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders one of flutter-wechat's hard-coded sample image URLs.
///
/// The source uses plain `Image.network`; the port uses the host's
/// [CachedNetworkImage] so demo avatars load exactly the same sample URLs
/// without a new dependency.
class FlutterWechatRemoteImage extends StatelessWidget {
  const FlutterWechatRemoteImage({
    required this.url,
    this.width,
    this.height,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => _placeholder(),
      errorWidget: (context, url, error) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Color(0xFFA9A9A9), size: 24.0),
    );
  }
}
