import 'dart:async';

import 'package:dashboard/features/short_video/short_video_player.dart';
import 'package:dashboard/features/short_video/short_video_music_title.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class ShortVideoPlayerState extends State<ShortVideoPlayer>
    with WidgetsBindingObserver {
  Player? _player;
  VideoController? _video;
  StreamSubscription<bool>? _playing;
  bool _isPlaying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      MediaKit.ensureInitialized();
      final player = Player();
      if (!mounted) {
        await player.dispose();
        return;
      }
      _player = player;
      _video = VideoController(player);
      _playing = player.stream.playing.listen((value) {
        if (mounted) setState(() => _isPlaying = value);
      });
      await player.setPlaylistMode(PlaylistMode.single);
      if (!mounted) return;
      await player.open(Media('asset:///${widget.clip.video}'));
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _toggle() async {
    final player = _player;
    if (player == null) return;
    try {
      if (_isPlaying) {
        await player.pause();
      } else {
        await player.play();
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_player?.pause());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_playing?.cancel());
    unawaited(_player?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(widget.clip.poster, fit: BoxFit.contain),
      if (_video != null) Video(controller: _video!, fit: BoxFit.contain),
      GestureDetector(behavior: HitTestBehavior.translucent, onTap: _toggle),
      if (!_isPlaying)
        Center(
          child: Image.asset(
            'assets/short_video/images/ic_playing.png',
            width: 50,
          ),
        ),
      if (_error != null)
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            '播放失败：$_error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      Positioned(
        bottom: 24,
        left: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('@MarcoChen', style: TextStyle(color: Colors.white)),
            Text('外星人来了，你们走不走', style: TextStyle(color: Colors.white)),
            ShortVideoMusicTitle(title: '三根皮带歌曲,哗啦啦啦啦啦啦啦啦啦'),
          ],
        ),
      ),
      Positioned(
        right: 12,
        bottom: 90,
        child: Column(
          children: [
            for (final icon in [
              'video_icon_praise.png',
              'video_msg_icon.png',
              'video_share_icon.png',
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Image.asset(
                  'assets/short_video/images/$icon',
                  width: 40,
                ),
              ),
            const Text('示例互动', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ],
  );
}
