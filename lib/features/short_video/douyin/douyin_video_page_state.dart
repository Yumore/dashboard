import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_headers.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_item.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_overlay.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_page.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class DouyinVideoPageState extends State<DouyinVideoPage> {
  late final bool _ownsApi;
  late final DouyinApi _api;
  late final DouyinVideoController _controller;
  late final PageController _pageController;
  late int _initialIndex;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DouyinApi();
    _controller = widget.controller ?? DouyinVideoController(api: _api);
    final upperBound = widget.entries.isEmpty ? 0 : widget.entries.length - 1;
    _initialIndex = widget.initialIndex.clamp(0, upperBound);
    _pageController = PageController(initialPage: _initialIndex);
    _controller.select(_initialIndex);
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_ownsApi) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load(widget.entries);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('抖音视频'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('正在解析播放地址…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }
    final error = _controller.error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    if (_controller.items.isEmpty) {
      return const Center(
        child: Text('榜单暂无视频', style: TextStyle(color: Colors.white70)),
      );
    }
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _controller.items.length,
      onPageChanged: (index) => setState(() => _controller.select(index)),
      itemBuilder: (context, index) => _buildPage(index),
    );
  }

  Widget _buildPage(int index) {
    final item = _controller.items[index];
    if (!item.hasPlayback) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: Colors.black,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Text(
              item.hasError ? item.error : '没有可播放地址',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (item.hasError)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton(
                  onPressed: _load,
                  child: const Text('重试'),
                ),
              ),
            ),
        ],
      );
    }
    final isCurrent = index == _controller.currentIndex;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (isCurrent)
          _buildPlayback(item)
        else
          const ColoredBox(
            color: Colors.black,
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.white24,
              ),
            ),
          ),
        Positioned.fill(
          child: SafeArea(
            child: DouyinVideoOverlay(
              item: item,
              onDetail: () => _openDetail(item),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayback(DouyinVideoItem item) {
    final builder = widget.playbackBuilder;
    if (builder != null) {
      return builder(context, item.playbackTitle, item.playUrl);
    }
    return MediaPlaybackPage(
      title: item.playbackTitle,
      sources: <MediaStreamSource>[
        MediaStreamSource(
          label: '720p',
          url: Uri.parse(item.playUrl),
          headers: DouyinHeaders.play(),
        ),
      ],
    );
  }

  void _openDetail(DouyinVideoItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DouyinDetailPage(
          awemeId: item.aweme.awemeId,
          api: _api,
        ),
      ),
    );
  }
}
