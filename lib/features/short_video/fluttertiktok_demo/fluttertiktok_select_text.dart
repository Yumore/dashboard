import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of the source `SelectText` in `flutter_tiktok/lib/views/selectText.dart`.
class FlutterTiktokSelectText extends StatelessWidget {
  const FlutterTiktokSelectText({
    required this.title,
    this.isSelect = true,
    this.onTap,
    super.key,
  });

  final String title;
  final bool isSelect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            title,
            style: isSelect
                ? FlutterTiktokPalette.big
                : FlutterTiktokPalette.bigWithOpacity,
          ),
        ),
      ),
    );
  }
}
