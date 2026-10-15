import 'package:dashboard/features/short_video/short_video_music_title_state.dart';
import 'package:flutter/material.dart';

class ShortVideoMusicTitle extends StatefulWidget {
  const ShortVideoMusicTitle({required this.title, super.key});

  final String title;

  @override
  State<ShortVideoMusicTitle> createState() => ShortVideoMusicTitleState();
}
