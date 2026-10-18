import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of `VideoUserInfo` from `flutter_tiktok/lib/views/tikTokVideo.dart`.
class FlutterTiktokVideoUserInfo extends StatelessWidget {
  const FlutterTiktokVideoUserInfo({
    required this.desc,
    this.bottomPadding = 16,
    super.key,
  });

  final String? desc;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12, right: 80, bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            FlutterTiktokDemoConfig.feedAuthor,
            style: FlutterTiktokPalette.big,
          ),
          const SizedBox(height: 6),
          Text(
            desc ?? FlutterTiktokDemoConfig.feedDescription,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: FlutterTiktokPalette.normal,
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(
                Icons.music_note,
                size: 14,
                color: FlutterTiktokPalette.white,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  FlutterTiktokDemoConfig.feedMusic,
                  maxLines: 9,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterTiktokPalette.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
