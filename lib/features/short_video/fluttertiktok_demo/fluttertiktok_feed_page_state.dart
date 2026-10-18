import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_feed_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_sample_video.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_video_page.dart';
import 'package:flutter/material.dart';

class FlutterTiktokFeedPageState extends State<FlutterTiktokFeedPage> {
  final List<FlutterTiktokSampleVideo> videos =
      FlutterTiktokSampleVideo.fetchVideo();
  final PageController controller = PageController();

  int currentIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: FlutterTiktokFeedPage.pageViewKey,
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (int index) => setState(() => currentIndex = index),
      itemBuilder: (BuildContext context, int index) {
        final FlutterTiktokSampleVideo video = videos[index];
        return FlutterTiktokVideoPage(
          video: video,
          favorite: widget.favorites[index] ?? false,
          bottomPadding: MediaQuery.sizeOf(context).aspectRatio < 0.55
              ? 16
              : 50,
          onFavorite: () => widget.onToggleFavorite(index),
          onDoubleTapFavorite: () => widget.onLike(index),
          onComment: () => widget.onComment(index),
          onShare: () {},
          onAvatar: widget.onAvatar,
        );
      },
    );
  }
}
