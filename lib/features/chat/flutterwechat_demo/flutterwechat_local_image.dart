import 'package:flutter/material.dart';

/// Renders one of the images bundled under `assets/flutterwechat_demo/`.
///
/// The source used `Image.asset('images/...')`; the port keeps the same files
/// under the host asset directory and falls back to a neutral placeholder if
/// the asset bundle does not have them registered yet.
class FlutterWechatLocalImage extends StatelessWidget {
  const FlutterWechatLocalImage(
    this.path, {
    this.width,
    this.height,
    this.fit,
    super.key,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE0E0E0),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 18.0),
      ),
    );
  }
}
