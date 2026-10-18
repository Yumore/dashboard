import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_detail_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_download_store.dart';
import 'package:dashboard/features/short_video/douyin/douyin_stat_chip.dart';
import 'package:dashboard/features/short_video/douyin/douyin_headers.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';

class DouyinDetailPageState extends State<DouyinDetailPage> {
  late final bool _ownsApi;
  late final DouyinApi _api;
  late final DouyinDetailController _controller;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DouyinApi();
    _controller = widget.controller ??
        DouyinDetailController(
          api: _api,
          downloadController: DouyinDownloadController(
            api: _api,
            store: DouyinDownloadStore(),
          ),
        );
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
    await _controller.load(widget.awemeId);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _download() async {
    await _controller.download();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('视频详情')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final aweme = _controller.aweme;
    if (aweme == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _controller.error ?? '没有加载到作品',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    final playError = _controller.playError;
    final saved = _controller.saved;
    final error = _controller.error;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(aweme.displayDesc, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: aweme.author?.avatarUrl == null ||
                      aweme.author!.avatarUrl.isEmpty
                  ? null
                  : NetworkImage(aweme.author!.avatarUrl),
              child: aweme.author?.avatarUrl == null ||
                      aweme.author!.avatarUrl.isEmpty
                  ? const Icon(Icons.person_outline)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(aweme.authorName, style: theme.textTheme.titleSmall),
                  Text(
                    aweme.authorHandle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            DouyinStatChip(label: '点赞', value: aweme.diggCount),
            DouyinStatChip(label: '评论', value: aweme.commentCount),
            DouyinStatChip(label: '分享', value: aweme.shareCount),
            DouyinStatChip(label: '播放', value: aweme.playCount),
          ],
        ),
        const SizedBox(height: 12),
        Text('音乐：${aweme.musicLabel}', style: theme.textTheme.bodyMedium),
        if (aweme.hashtagLabel.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Text(aweme.hashtagLabel, style: theme.textTheme.bodySmall),
        ],
        if (aweme.riskLabel.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.warning_amber_outlined,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aweme.riskLabel,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        const Divider(height: 32),
        Text('播放地址', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (playError != null)
          Text(
            playError,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        if (_controller.playUrl.isNotEmpty)
          Text(
            _controller.playUrl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            FilledButton.icon(
              onPressed: _controller.playUrl.isEmpty ? null : _play,
              icon: const Icon(Icons.play_arrow),
              label: const Text('播放视频'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _controller.isDownloading ? null : _download,
              icon: const Icon(Icons.download_outlined),
              label: Text(_controller.isDownloading ? '正在保存…' : '下载并保存'),
            ),
          ],
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(error, style: TextStyle(color: theme.colorScheme.error)),
        ],
        if (saved != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('已保存：${saved.path}'),
          ),
        ],
      ],
    );
  }

  void _play() {
    final url = _controller.playUrl;
    if (url.isEmpty) {
      return;
    }
    final builder = widget.playbackBuilder;
    if (builder != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => builder(context, '抖音视频', url),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: '抖音视频',
          sources: <MediaStreamSource>[
            MediaStreamSource(
              label: '720p',
              url: Uri.parse(url),
              headers: DouyinHeaders.play(),
            ),
          ],
        ),
      ),
    );
  }
}
