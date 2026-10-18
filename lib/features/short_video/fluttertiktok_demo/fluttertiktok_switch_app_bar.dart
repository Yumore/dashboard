import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokSwitchAppbar` from
/// `flutter_tiktok/lib/views/tilTokAppBar.dart`.
class FlutterTiktokSwitchAppBar extends StatelessWidget {
  const FlutterTiktokSwitchAppBar({
    required this.labels,
    required this.index,
    this.onSwitch,
    super.key,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int>? onSwitch;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back2,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: onSwitch == null ? null : () => onSwitch!(i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Text(
                  labels[i],
                  style: i == index
                      ? FlutterTiktokPalette.big
                      : FlutterTiktokPalette.bigWithOpacity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
