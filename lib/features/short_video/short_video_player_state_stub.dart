import 'package:dashboard/features/short_video/short_video_player.dart';
import 'package:flutter/material.dart';

/// Web 平台没有 media_kit 原生播放库时的降级播放器。
class ShortVideoPlayerState extends State<ShortVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 40),
            const SizedBox(height: 8),
            const Text(
              '当前平台暂不支持内嵌短视频播放',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
