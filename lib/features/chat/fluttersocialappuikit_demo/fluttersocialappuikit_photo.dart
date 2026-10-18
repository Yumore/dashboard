import 'package:flutter/material.dart';

/// Picture widget for the ported FlutterSocialAppUIKit demo.
///
/// The source renders every picture with `AssetImage` pointing at the ten
/// `assets/images/cm*.jpeg` files it bundles; it contains no remote image URL
/// at all (see `flutterSocialAppUIKitRemoteSampleImageUrls`). Those files were
/// copied into the host's `assets/fluttersocialappuikit_demo/`, so a local
/// source string is loaded with [Image.asset] and only falls back to the
/// placeholder if the file is missing (or, as in widget tests, unregistered).
class FlutterSocialAppUIKitPhoto extends StatelessWidget {
  const FlutterSocialAppUIKitPhoto({
    required this.source,
    required this.width,
    required this.height,
    this.circle = false,
    this.borderRadius,
    this.icon = Icons.person_outline,
    super.key,
  });

  final String source;
  final double width;
  final double height;
  final bool circle;
  final BorderRadius? borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // The source relies on `Image` staying hit-transparent: its feed pictures
    // sit under an `InkWell` and its avatars under `ListTile`s. `RenderImage`
    // is hit-testable, so the picture is wrapped in `IgnorePointer` to let taps
    // reach the widgets the source intended them for.
    final Widget image = IgnorePointer(
      child: Image.asset(
        source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
          return _placeholder();
        },
      ),
    );

    if (circle) {
      return ClipOval(
        child: SizedBox(width: width, height: height, child: image),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(7.0),
      child: SizedBox(width: width, height: height, child: image),
    );
  }

  Widget _placeholder() {
    final double shortest = width < height ? width : height;
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE3E7EE),
      child: Center(
        child: Icon(
          icon,
          size: shortest * 0.45,
          color: const Color(0xFF9AA6B8),
        ),
      ),
    );
  }
}
