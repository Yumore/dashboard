import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokAppbar` from `flutter_tiktok/lib/views/tilTokAppBar.dart`.
class FlutterTiktokAppBar extends StatelessWidget {
  const FlutterTiktokAppBar({required this.title, this.onBack, super.key});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back2,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 44,
        child: Row(
          children: <Widget>[
            GestureDetector(
              key: const Key('fluttertiktok_app_bar_back'),
              behavior: HitTestBehavior.opaque,
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 48,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 18,
                  color: FlutterTiktokPalette.white,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(title, style: FlutterTiktokPalette.big),
              ),
            ),
            const Opacity(
              opacity: 0,
              child: Icon(Icons.panorama_fish_eye, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
