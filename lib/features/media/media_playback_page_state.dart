import 'dart:async';

import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/playback_position_store.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaPlaybackPageState extends State<MediaPlaybackPage>
    with WidgetsBindingObserver {
  final _positions = PlaybackPositionStore();
  Player? _player;
  VideoController? _video;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<String>? _errorSubscription;
  Duration _position = Duration.zero;
  int _savedSecond = -1;
  int _sourceIndex = 0;
  bool _opening = false;
  bool _historyLoaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      MediaKit.ensureInitialized();
      final player = Player();
      _player = player;
      _video = VideoController(player);
      _positionSubscription = player.stream.position.listen(_rememberPosition);
      _errorSubscription = player.stream.error.listen((error) {
        if (mounted) setState(() => _error = error);
      });
      final id = widget.historyId;
      if (id != null) _position = await _positions.load(id);
      if (!mounted) return;
      _historyLoaded = true;
      await _open(0);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  void _rememberPosition(Duration position) {
    if (_opening) return;
    _position = position;
    if (widget.historyId == null || position.inSeconds ~/ 5 == _savedSecond) {
      return;
    }
    _savedSecond = position.inSeconds ~/ 5;
    unawaited(_persist());
  }

  Future<void> _persist() async {
    final id = widget.historyId;
    if (_historyLoaded && id != null) await _positions.save(id, _position);
  }

  Future<void> _open(int index) async {
    final player = _player;
    if (player == null || _opening) return;
    setState(() {
      _opening = true;
      _error = null;
      _sourceIndex = index;
    });
    final source = widget.sources[index];
    final resume = widget.historyId == null ? Duration.zero : _position;
    try {
      await player.open(
        Media(
          source.url.toString(),
          httpHeaders: source.headers,
          start: resume,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _navigate(WidgetBuilder builder) async {
    await _persist();
    await _player?.pause();
    if (!mounted) return;
    unawaited(
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: builder)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_persist());
      unawaited(_player?.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_persist());
    unawaited(_positionSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    unawaited(_player?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: _video == null
                ? Center(child: Text(_error ?? '正在初始化播放器…'))
                : Video(controller: _video!),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('播放失败：$_error'),
            ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                IconButton(
                  tooltip: '上一集',
                  onPressed: widget.previousPage == null
                      ? null
                      : () => _navigate(widget.previousPage!),
                  icon: const Icon(Icons.skip_previous),
                ),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _sourceIndex,
                    items: [
                      for (var i = 0; i < widget.sources.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(widget.sources[i].label),
                        ),
                    ],
                    onChanged: _opening
                        ? null
                        : (i) {
                            if (i != null) _open(i);
                          },
                  ),
                ),
                IconButton(
                  tooltip: '重试',
                  onPressed: _opening
                      ? null
                      : () => _player == null
                            ? _initialize()
                            : _open(_sourceIndex),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: '下一集',
                  onPressed: widget.nextPage == null
                      ? null
                      : () => _navigate(widget.nextPage!),
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
