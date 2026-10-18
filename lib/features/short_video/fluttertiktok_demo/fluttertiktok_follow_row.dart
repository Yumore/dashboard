import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_remote_image.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_placeholder.dart';
import 'package:flutter/material.dart';

/// Port of `FollowRow` from `flutter_tiktok/lib/pages/followPage.dart`.
class FlutterTiktokFollowRow extends StatelessWidget {
  const FlutterTiktokFollowRow({
    required this.index,
    required this.isFavorite,
    required this.onFavorite,
    required this.onComment,
    this.onShare,
    super.key,
  });

  final int index;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onComment;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 32,
                height: 32,
                child: ClipOval(
                  child: FlutterTiktokRemoteImage(
                    url: FlutterTiktokDemoConfig.avatarUrl,
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  FlutterTiktokDemoConfig.followAuthor,
                  style: FlutterTiktokPalette.normalW,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 6, 50, 8),
            child: Text(
              FlutterTiktokDemoConfig.followDescription,
              style: FlutterTiktokPalette.normal,
            ),
          ),
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Align(
              alignment: Alignment.topLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const FlutterTiktokVideoPlaceholder(aspectRatio: 6 / 9),
              ),
            ),
          ),
          Opacity(
            opacity: 0.8,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 12, 8),
              child: Row(
                children: <Widget>[
                  Text(
                    FlutterTiktokDemoConfig.followDate,
                    style: FlutterTiktokPalette.smallWithOpacity,
                  ),
                  const Spacer(),
                  _rowButton(
                    key: Key('fluttertiktok_follow_share_$index'),
                    iconData: Icons.share,
                    title: '分享',
                    onTap: onShare,
                  ),
                  _rowButton(
                    key: Key('fluttertiktok_follow_comment_$index'),
                    iconData: Icons.mode_comment,
                    size: FlutterTiktokPalette.iconNormal - 2,
                    title: '评论',
                    onTap: onComment,
                  ),
                  _rowButton(
                    key: Key('fluttertiktok_follow_like_$index'),
                    iconData: Icons.favorite,
                    title: '赞',
                    color: isFavorite
                        ? FlutterTiktokPalette.red
                        : FlutterTiktokPalette.white,
                    onTap: onFavorite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowButton({
    required Key key,
    required IconData iconData,
    required String title,
    double? size,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: <Widget>[
            Icon(
              iconData,
              size: size ?? FlutterTiktokPalette.iconNormal,
              color: color,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(title, style: FlutterTiktokPalette.small),
            ),
          ],
        ),
      ),
    );
  }
}
