import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_controller.dart';
import 'package:dashboard/features/movie/dytt/dytt_detail_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:dashboard/features/movie/dytt/dytt_playback.dart';
import 'package:dashboard/features/movie/dytt/dytt_signing_notice.dart';
import 'package:flutter/material.dart';

/// 详情页状态：签名可用时请求详情，再把 HTTP(S) 线路交给宿主播放器。
class DyttDetailPageState extends State<DyttDetailPage> {
  late final DyttDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DyttDetailController(
      api: widget.api,
      categoryId: widget.movie.categoryId,
      movieId: widget.movie.id,
      initial: widget.movie,
    )..addListener(_onChanged);
    // 签名不可用时不发请求：默认签名器不会产生任何伪造值。
    if (widget.api.signingSupported) _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  /// 从第 [index] 条可播放线路开始连续播放；与源站一样保持原顺序。
  void _play(DyttMovieDetail detail, DyttPlayback playback, int index) {
    final all = playback.playable;
    if (all.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该片暂无可播放的 HTTP(S) 地址')));
      return;
    }
    final start = index < 0
        ? 0
        : index >= all.length
        ? all.length - 1
        : index;
    final sources = <MediaStreamSource>[
      for (var i = start; i < all.length; i++)
        MediaStreamSource(label: '线路 ${i + 1}', url: all[i].uri),
    ];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: detail.name,
          sources: sources,
          historyId: 'dytt.${detail.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = _controller.movie ?? widget.movie;
    return Scaffold(
      appBar: AppBar(title: Text(movie.name)),
      body: widget.api.signingSupported
          ? _body(movie)
          : ListView(
              children: const [
                DyttSigningNotice(),
                SizedBox(height: 32),
                Center(child: Text('签名不可用，未请求电影天堂详情接口')),
              ],
            ),
    );
  }

  Widget _body(DyttMovieDetail movie) {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _controller.load,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    final playback = DyttPlayback.fromDownloadUrl(movie.downloadUrl);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (movie.homePicUrl.isNotEmpty) _poster(movie.homePicUrl),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.name, style: Theme.of(context).textTheme.titleMedium),
              if (movie.publishTime.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '发布时间：${movie.publishTime}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Text(movie.content.isEmpty ? '还没有内容！请检查网络。' : movie.content),
            ],
          ),
        ),
        const Divider(height: 1),
        _playbackSection(movie, playback),
      ],
    );
  }

  Widget _poster(String url) {
    return Container(
      color: const Color(0xFF222730),
      height: 300,
      alignment: Alignment.center,
      child: CachedNetworkImage(
        imageUrl: url,
        width: 150,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (_, _) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _playbackSection(DyttMovieDetail movie, DyttPlayback playback) {
    final urls = playback.playable;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('播放线路', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (urls.isEmpty)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.play_disabled_outlined),
              title: Text('暂无可播放的 HTTP(S) 地址'),
              subtitle: Text('源站只提供 ftp/ed2k 等下载链接时，宿主播放器无法直接播放。'),
            )
          else ...[
            FilledButton.icon(
              onPressed: () => _play(movie, playback, 0),
              icon: const Icon(Icons.play_arrow),
              label: Text('播放（${urls.length} 条线路）'),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < urls.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link),
                title: Text('线路 ${i + 1}'),
                subtitle: Text(
                  urls[i].fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.play_circle_outline),
                onTap: () => _play(movie, playback, i),
              ),
          ],
        ],
      ),
    );
  }
}
