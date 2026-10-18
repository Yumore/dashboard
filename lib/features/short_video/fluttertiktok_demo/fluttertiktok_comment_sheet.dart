import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_remote_image.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokCommentBottomSheet` from
/// `flutter_tiktok/lib/views/tikTokCommentBottomSheet.dart`.
///
/// The source replaced Flutter's default bottom sheet with a vendored copy so
/// this sheet could use 12/16 of the screen height; the same height is applied
/// here with `isScrollControlled`.
class FlutterTiktokCommentSheet extends StatelessWidget {
  const FlutterTiktokCommentSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 12 / 16,
        child: const FlutterTiktokCommentSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FlutterTiktokPalette.back1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(
            height: 24,
            child: Center(
              child: Text(
                FlutterTiktokDemoConfig.commentSheetTitle,
                style: FlutterTiktokPalette.small,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: FlutterTiktokDemoConfig.commentRowCount,
              itemBuilder: (_, _) => _commentRow(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: SizedBox(
              width: 36,
              height: 36,
              child: ClipOval(
                child: FlutterTiktokRemoteImage(
                  url: FlutterTiktokDemoConfig.avatarUrl,
                  width: 36,
                  height: 36,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  FlutterTiktokDemoConfig.commentAuthor,
                  style: FlutterTiktokPalette.smallWithOpacity,
                ),
                const SizedBox(height: 2),
                Text(
                  FlutterTiktokDemoConfig.commentText,
                  style: FlutterTiktokPalette.normal,
                ),
              ],
            ),
          ),
          Opacity(
            opacity: 0.3,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.favorite,
                  size: 20,
                  color: FlutterTiktokPalette.white,
                ),
                Text(
                  FlutterTiktokDemoConfig.commentLikeCount,
                  style: FlutterTiktokPalette.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
