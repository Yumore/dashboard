import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// The source's unfilled banner slot used by the message and search pages.
class FlutterTiktokAdPlaceholder extends StatelessWidget {
  const FlutterTiktokAdPlaceholder({
    this.margin = const EdgeInsets.fromLTRB(12, 16, 12, 16),
    super.key,
  });

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: AspectRatio(
        aspectRatio: 4,
        child: Container(
          decoration: BoxDecoration(
            color: FlutterTiktokPalette.darkGray,
            border: Border.all(color: FlutterTiktokPalette.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              FlutterTiktokDemoConfig.adPlaceholderText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0x1AFFFFFF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
