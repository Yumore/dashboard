import 'package:flutter/material.dart';

/// Renders one of the images bundled under `assets/flutterwechatfull_demo/`.
///
/// The source used `Image.asset`; the port keeps the same files and falls back
/// to a neutral placeholder while the asset directory is not registered yet,
/// so a missing `pubspec.yaml` entry never crashes a screen.
class FlutterWechatFullLocalImage extends StatelessWidget {
  const FlutterWechatFullLocalImage({
    required this.path,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.borderRadius,
    super.key,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE0E0E0),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 18.0),
      ),
    );
    if (borderRadius == null) {
      return image;
    }
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
