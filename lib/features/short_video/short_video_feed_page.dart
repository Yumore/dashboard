import 'package:dashboard/features/short_video/short_video_clip.dart';
import 'package:dashboard/features/short_video/short_video_feed_page_state.dart';
import 'package:flutter/material.dart';

class ShortVideoFeedPage extends StatefulWidget {
  const ShortVideoFeedPage({super.key, this.clipBuilder});

  /// Permits interaction tests without starting a native decoder.
  final Widget Function(ShortVideoClip clip)? clipBuilder;

  @override
  State<ShortVideoFeedPage> createState() => ShortVideoFeedPageState();
}
