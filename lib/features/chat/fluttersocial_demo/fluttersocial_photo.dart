import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image widget for the ported flutter-social demo.
///
/// The source renders every picture with `AssetImage` pointing at files the
/// source project bundles under `assets/images/` — it contains no remote image
/// URL at all (see [FlutterSocialDemoConfig]'s
/// `flutterSocialDemoRemoteSampleImageUrls`). Those 15 files were copied into the
/// host's `assets/fluttersocial_demo/` and registered in `pubspec.yaml`, so a
/// local source string is loaded with [Image.asset] and only falls back to the
/// placeholder if the file is missing (or, as in widget tests, unregistered).
///
/// A real `http(s)` source — the shape the host's other migrated demos use — is
/// loaded through the host's `cached_network_image`, so the widget is ready for
/// one and the port keeps the host's single image-loading path.
class FlutterSocialPhoto extends StatelessWidget {
  const FlutterSocialPhoto({
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

  bool get isRemote =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    // The source stacks its landing picture over the LOG IN / SIGN UP buttons
    // and puts feed avatars under `InkWell`s, relying on a plain `Image` staying
    // hit-transparent. `RenderImage` is in fact hit-testable, so the whole
    // picture is wrapped in `IgnorePointer` to reproduce that behaviour and let
    // taps reach the widgets underneath.
    final Widget image = IgnorePointer(
      child: isRemote
          ? CachedNetworkImage(
              imageUrl: source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) => _placeholder(),
              errorWidget: (_, _, _) => _placeholder(),
            )
          : Image.asset(
              source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
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
    final shortest = width < height ? width : height;
    // `Image` never absorbs pointer events, and the source relies on that: its
    // landing picture is stacked over the LOG IN / SIGN UP buttons and its feed
    // avatars sit under `InkWell`s. The stand-in must stay hit-transparent too,
    // otherwise it would swallow taps the source lets through.
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFE9DED4),
        child: Center(
          child: Icon(
            icon,
            size: shortest * 0.45,
            color: const Color(0xFFB39A85),
          ),
        ),
      ),
    );
  }
}
