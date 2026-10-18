import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_billboard_tile.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_video_page.dart';
import 'package:flutter/material.dart';

class DouyinFeedPageState extends State<DouyinFeedPage> {
  late final bool _ownsApi;
  late final DouyinApi _api;
  late final DouyinFeedController _controller;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DouyinApi();
    _controller = widget.controller ?? DouyinFeedController(api: _api);
    _load();
  }

  @override
  void dispose() {
    if (_ownsApi) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('抖音热门榜')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _controller.error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    if (_controller.entries.isEmpty) {
      return const Center(child: Text('榜单暂无数据'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _controller.entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = _controller.entries[index];
          return DouyinBillboardTile(
            entry: entry,
            onTap: () => _openVideo(index),
          );
        },
      ),
    );
  }

  void _openVideo(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DouyinVideoPage(
          entries: _controller.entries,
          initialIndex: index,
          api: _api,
          playbackBuilder: widget.playbackBuilder,
        ),
      ),
    );
  }
}
