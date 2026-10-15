import 'dart:async';

import 'package:dashboard/features/short_video/short_video_music_title.dart';
import 'package:flutter/material.dart';

class ShortVideoMusicTitleState extends State<ShortVideoMusicTitle> {
  static const _interval = Duration(seconds: 3);
  static const _travel = Duration(milliseconds: 1500);

  final ScrollController _scroll = ScrollController();
  Timer? _cycle;
  Timer? _return;

  @override
  void initState() {
    super.initState();
    _cycle = Timer.periodic(_interval, (_) => _scrollOutAndBack());
  }

  void _scrollOutAndBack() {
    if (!mounted || !_scroll.hasClients) return;
    final maximum = _scroll.position.maxScrollExtent;
    if (maximum <= 0) return;
    unawaited(
      _scroll.animateTo(maximum, duration: _travel, curve: Curves.linear),
    );
    _return?.cancel();
    _return = Timer(_travel, () {
      if (mounted && _scroll.hasClients) {
        unawaited(
          _scroll.animateTo(0, duration: _travel, curve: Curves.linear),
        );
      }
    });
  }

  @override
  void dispose() {
    _cycle?.cancel();
    _return?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    height: 25,
    child: ListView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Text(
          widget.title,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}
