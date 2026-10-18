import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of `TopToolRow` from `flutter_tiktok/lib/views/topToolRow.dart`.
class FlutterTiktokTopToolRow extends StatelessWidget {
  const FlutterTiktokTopToolRow({
    this.right,
    this.canPop = false,
    this.onPop,
    this.backKey,
    super.key,
  });

  final Widget? right;
  final bool canPop;
  final VoidCallback? onPop;
  final Key? backKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (canPop)
          GestureDetector(
            key: backKey,
            onTap: onPop ?? () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0x5C000000),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: FlutterTiktokPalette.white,
              ),
            ),
          ),
        const Spacer(),
        ?right,
      ],
    );
  }
}
