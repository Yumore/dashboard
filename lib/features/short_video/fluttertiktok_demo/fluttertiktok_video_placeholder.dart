import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Static stand-in for the source's remote video surface.
///
/// The source fed `https://static.ybhospital.net/<file>` into `video_player`.
/// This demo never fetches or plays those samples; it draws the source's black
/// 9:16 frame with a visible placeholder glyph instead.
class FlutterTiktokVideoPlaceholder extends StatelessWidget {
  const FlutterTiktokVideoPlaceholder({
    this.aspectRatio = 9 / 16,
    this.showPlayIcon = true,
    super.key,
  });

  final double aspectRatio;
  final bool showPlayIcon;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ColoredBox(
        color: FlutterTiktokPalette.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const Center(
              child: Icon(
                Icons.movie_outlined,
                size: 64,
                color: Color(0x33FFFFFF),
              ),
            ),
            if (showPlayIcon)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 120,
                  color: Color(0x66FFFFFF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
