import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_avatar.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokButtonColumn` from
/// `flutter_tiktok/lib/views/tikTokVideoButtonColumn.dart`.
class FlutterTiktokVideoButtonColumn extends StatelessWidget {
  const FlutterTiktokVideoButtonColumn({
    required this.sampleId,
    required this.isFavorite,
    required this.onFavorite,
    required this.onComment,
    required this.onShare,
    required this.onAvatar,
    this.bottomPadding = 50,
    super.key,
  });

  final String sampleId;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onAvatar;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      margin: EdgeInsets.only(right: 12, bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FlutterTiktokAvatar(
            key: Key('fluttertiktok_avatar_$sampleId'),
            addBadgeKey: Key('fluttertiktok_avatar_add_$sampleId'),
            url: FlutterTiktokDemoConfig.avatarUrl,
            onTap: onAvatar,
          ),
          const SizedBox(height: 6),
          GestureDetector(
            key: Key('fluttertiktok_favorite_$sampleId'),
            behavior: HitTestBehavior.opaque,
            onTap: onFavorite,
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.favorite,
                  size: 40,
                  color: isFavorite
                      ? FlutterTiktokPalette.red
                      : FlutterTiktokPalette.white,
                ),
                const SizedBox(height: 2),
                Text(
                  FlutterTiktokDemoConfig.favoriteCount,
                  style: FlutterTiktokPalette.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            key: Key('fluttertiktok_comment_$sampleId'),
            behavior: HitTestBehavior.opaque,
            onTap: onComment,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.mode_comment,
                  size: 36,
                  color: FlutterTiktokPalette.white,
                ),
                const SizedBox(height: 2),
                Text(
                  FlutterTiktokDemoConfig.commentCount,
                  style: FlutterTiktokPalette.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            key: Key('fluttertiktok_share_$sampleId'),
            behavior: HitTestBehavior.opaque,
            onTap: onShare,
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.share,
                  size: 40,
                  color: FlutterTiktokPalette.white,
                ),
                const SizedBox(height: 2),
                Text(
                  FlutterTiktokDemoConfig.shareCount,
                  style: FlutterTiktokPalette.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(width: 56, height: 56),
        ],
      ),
    );
  }
}
