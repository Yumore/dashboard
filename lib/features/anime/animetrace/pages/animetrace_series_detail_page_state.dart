import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode_list.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_episode_note_page.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_series_detail_page.dart';
import 'package:dashboard/features/anime/animetrace/widgets/animetrace_cover.dart';
import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/media/media_stream_source.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// State of [AnimeTraceSeriesDetailPage].
///
/// Everything is loaded once from local tables; the only network call is the
/// explicit "重新抓取信息" / "播放" action.
class AnimeTraceSeriesDetailPageState
    extends State<AnimeTraceSeriesDetailPage> {
  List<AnimeTraceEpisode> _episodes = const <AnimeTraceEpisode>[];
  Set<int> _notedEpisodeNumbers = const <int>{};
  String _coverRoot = '';
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final anime = widget.anime;
      final watched = await widget.historyDao.getWatchedEpisodeDates(
        anime.animeId,
        reviewNumber: anime.reviewNumber,
      );
      final noted = await widget.episodeNoteDao.getNotedEpisodeNumbers(
        anime.animeId,
        reviewNumber: anime.reviewNumber,
      );
      final coverRoot = await widget.imageStore.coverImageRootDirPath();
      if (!mounted) return;
      setState(() {
        _episodes = AnimeTraceEpisodeList.build(
          anime,
          watched,
          reviewNumber: anime.reviewNumber,
        );
        _notedEpisodeNumbers = noted;
        _coverRoot = coverRoot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _toggleWatched(AnimeTraceEpisode episode) async {
    final anime = widget.anime;
    if (episode.isChecked()) {
      await widget.historyDao.deleteHistory(
        anime.animeId,
        episode.number,
        reviewNumber: episode.reviewNumber,
      );
    } else {
      await widget.historyDao.insertHistory(
        animeId: anime.animeId,
        episodeNumber: episode.number,
        reviewNumber: episode.reviewNumber,
      );
    }
    widget.onChanged();
    await _load();
  }

  Future<void> _openNote(AnimeTraceEpisode episode) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AnimeTraceEpisodeNotePage(
          anime: widget.anime,
          episode: episode,
          episodeNoteDao: widget.episodeNoteDao,
          imageStore: widget.imageStore,
        ),
      ),
    );
    widget.onChanged();
    await _load();
  }

  Future<void> _refreshInfo() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final refreshed = await widget.repository.climbAnimeInfo(widget.anime);
      await widget.animeDao.updateAnimeInfo(refreshed);
      await _load();
      widget.onChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已更新作品信息')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失败：$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _play(AnimeTraceEpisode episode) async {
    if (_busy) return;
    setState(() => _busy = true);
    String? streamUrl;
    String? failure;
    try {
      streamUrl = await widget.repository.resolveVideoUrl(
        widget.anime,
        episodeNumber: episode.number,
      );
    } catch (error) {
      failure = '$error';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    if (streamUrl == null || streamUrl.isEmpty) {
      await _showNoStreamDialog(failure);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: '${widget.anime.animeName} ${episode.caption}',
          sources: <MediaStreamSource>[
            MediaStreamSource(label: '线路 1', url: Uri.parse(streamUrl!)),
          ],
        ),
      ),
    );
    // Watching to the end is not detectable from here; the user marks it.
    if (!mounted) return;
  }

  Future<void> _showNoStreamDialog(String? failure) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('没有可播放的地址'),
        content: Text(
          failure == null ? '该站点没有暴露可直接播放的视频流。' : '解析播放地址失败：$failure',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final uri = Uri.tryParse(widget.anime.animeUrl);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('在浏览器打开'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anime.animeName, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            tooltip: '评分笔记',
            icon: const Icon(Icons.star_border),
            onPressed: () => unawaited(_openNote(AnimeTraceEpisode(0))),
          ),
          IconButton(
            tooltip: '重新抓取信息',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : () => unawaited(_refreshInfo()),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              Text('加载失败：$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => unawaited(_load()),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final anime = widget.anime;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimeTraceCover(
                  url: anime.animeCoverUrl,
                  localRoot: _coverRoot,
                  width: 88,
                  height: 118,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        anime.animeName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (anime.nameAnother.isNotEmpty)
                        Text('又名：${anime.nameAnother}'),
                      if (anime.infoFirstLine.isNotEmpty)
                        Text(anime.infoFirstLine),
                      Text(anime.infoSecondLine),
                      if (anime.animeUrl.isNotEmpty)
                        Text(
                          anime.animeUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (anime.animeDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                anime.animeDesc,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const Divider(),
          if (_episodes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('暂无可播放的剧集，试试"重新抓取信息"')),
            )
          else
            for (final episode in _episodes)
              ListTile(
                dense: true,
                leading: Checkbox(
                  value: episode.isChecked(),
                  onChanged: (_) => unawaited(_toggleWatched(episode)),
                ),
                title: Text(episode.caption),
                subtitle: episode.isChecked()
                    ? Text('已看：${episode.dateTime}')
                    : null,
                onTap: () => unawaited(_toggleWatched(episode)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: '笔记',
                      icon: Icon(
                        _notedEpisodeNumbers.contains(episode.number)
                            ? Icons.edit_note
                            : Icons.note_add_outlined,
                      ),
                      onPressed: () => unawaited(_openNote(episode)),
                    ),
                    IconButton(
                      tooltip: '播放',
                      icon: const Icon(Icons.play_arrow),
                      onPressed: _busy ? null : () => unawaited(_play(episode)),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
