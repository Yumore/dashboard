import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_sample_video.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_button_column.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_placeholder.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_user_info.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokVideoPage` from
/// `flutter_tiktok/lib/views/tikTokVideo.dart`.
///
/// Playback is intentionally dead: the source played remote sample MP4s with
/// `video_player`, which this static demo does not reproduce. A single tap is
/// inert; a double tap only performs the source's like action.
class FlutterTiktokVideoPage extends StatelessWidget {
  const FlutterTiktokVideoPage({
    required this.video,
    this.aspectRatio = 9 / 16,
    this.favorite = false,
    this.onFavorite,
    this.onDoubleTapFavorite,
    this.onComment,
    this.onShare,
    this.onAvatar,
    this.showActions = true,
    this.showUserInfo = true,
    this.showPauseIcon = true,
    this.bottomPadding = 16,
    super.key,
  });

  final FlutterTiktokSampleVideo video;
  final double aspectRatio;
  final bool favorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onDoubleTapFavorite;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAvatar;
  final bool showActions;
  final bool showUserInfo;
  final bool showPauseIcon;
  final double bottomPadding;

  static Key gestureKey(String sampleId) =>
      Key('fluttertiktok_gesture_$sampleId');

  @override
  Widget build(BuildContext context) {
    final String sampleId = video.desc ?? 'sample';
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ColoredBox(color: FlutterTiktokPalette.black),
        Center(
          child: FlutterTiktokVideoPlaceholder(
            aspectRatio: aspectRatio,
            showPlayIcon: false,
          ),
        ),
        if (showPauseIcon)
          const Center(
            child: Icon(
              Icons.play_circle_outline,
              size: 120,
              color: Color(0x66FFFFFF),
            ),
          ),
        Positioned.fill(
          child: GestureDetector(
            key: gestureKey(sampleId),
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            onDoubleTap: onDoubleTapFavorite ?? onFavorite,
            child: const SizedBox.expand(),
          ),
        ),
        if (showUserInfo)
          Align(
            alignment: Alignment.bottomLeft,
            child: FlutterTiktokVideoUserInfo(
              desc: video.desc,
              bottomPadding: bottomPadding,
            ),
          ),
        if (showActions)
          Positioned(
            right: 0,
            bottom: 0,
            child: FlutterTiktokVideoButtonColumn(
              sampleId: sampleId,
              isFavorite: favorite,
              onFavorite: onFavorite ?? () {},
              onComment: onComment ?? () {},
              onShare: onShare ?? () {},
              onAvatar: onAvatar ?? () {},
              bottomPadding: bottomPadding,
            ),
          ),
      ],
    );
  }
}
