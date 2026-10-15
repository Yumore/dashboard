import 'package:dashboard/features/short_video/short_video_clip.dart';
import 'package:dashboard/features/short_video/short_video_feed_page.dart';
import 'package:dashboard/features/short_video/short_video_player.dart';
import 'package:flutter/material.dart';

class ShortVideoFeedPageState extends State<ShortVideoFeedPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: const Text('本地视频演示')),
    body: PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: ShortVideoClip.samples.length,
      onPageChanged: (index) => setState(() => _index = index),
      itemBuilder: (context, index) {
        final clip = ShortVideoClip.samples[index];
        // Preloaded neighbors show posters; only the visible clip has a player.
        if (index != _index) {
          return Image.asset(clip.poster, fit: BoxFit.contain);
        }
        return widget.clipBuilder?.call(clip) ??
            ShortVideoPlayer(key: ValueKey(clip.video), clip: clip);
      },
    ),
  );
}
