import 'package:dashboard/features/short_video/short_video_clip.dart';
import 'package:dashboard/features/short_video/short_video_player_state.dart';
import 'package:flutter/material.dart';

class ShortVideoPlayer extends StatefulWidget {
  const ShortVideoPlayer({super.key, required this.clip});

  final ShortVideoClip clip;

  @override
  State<ShortVideoPlayer> createState() => ShortVideoPlayerState();
}
