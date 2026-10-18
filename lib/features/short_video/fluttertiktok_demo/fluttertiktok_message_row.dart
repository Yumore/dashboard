import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_remote_image.dart';
import 'package:flutter/material.dart';

/// Port of `UserMsgRow` from `flutter_tiktok/lib/views/userMsgRow.dart`.
class FlutterTiktokMessageRow extends StatelessWidget {
  const FlutterTiktokMessageRow({
    this.lead,
    this.title,
    this.desc,
    this.reverse = false,
    this.date = FlutterTiktokDemoConfig.messageDate,
    super.key,
  });

  final Widget? lead;
  final String? title;
  final String? desc;
  final bool reverse;
  final String date;

  @override
  Widget build(BuildContext context) {
    final Widget titleText = Text(
      title ?? FlutterTiktokDemoConfig.defaultMessageTitle,
      style: FlutterTiktokPalette.normalW,
    );
    final Widget descText = Text(
      desc ?? FlutterTiktokDemoConfig.defaultMessageDesc,
      style: FlutterTiktokPalette.smallWithOpacity,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10, bottom: 8),
            child:
                lead ??
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: FlutterTiktokRemoteImage(
                      url: FlutterTiktokDemoConfig.avatarUrl,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (reverse) descText else titleText,
                const SizedBox(height: 2),
                if (reverse) titleText else descText,
              ],
            ),
          ),
          Text(date, style: FlutterTiktokPalette.smallWithOpacity),
        ],
      ),
    );
  }
}
