import 'package:dashboard/features/media/media_playback_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_detail_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_network_image.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_episode.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source_selector.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_view.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_stream_sources.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_video_detail.dart';
import 'package:flutter/material.dart';

class FlutterMoviesDetailPageState extends State<FlutterMoviesDetailPage> {
  FlutterMoviesVideoDetail? _detail;

  /// 已按源站规则过滤（去掉 ckm3u8）并按分集数降序排序。
  List<FlutterMoviesPlaySource> _sources = const <FlutterMoviesPlaySource>[];
  int _sourceIndex = 0;
  String? _error;
  bool _loading = true;
  bool _introExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await widget.api.videoDetail(widget.vodId);
      final sources = FlutterMoviesPlaySourceSelector.select(
        detail.playSources,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _sources = sources;
        _sourceIndex = 0;
        _loading = false;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        _error = exception is FlutterMoviesException
            ? exception.message
            : '$exception';
        _loading = false;
      });
    }
  }

  FlutterMoviesPlaySource? get _selectedSource =>
      _sources.isEmpty ? null : _sources[_sourceIndex];

  void _selectSource(int index) => setState(() => _sourceIndex = index);

  /// 打开 host 的 media_kit 播放页；地址全部来自 CMS，未做任何拼接。
  ///
  /// MediaPlaybackPage 的线路列表只能从第一条开始播，因此从第 [from] 集点进去
  /// 时把该集及其之后的剧集作为列表传入，之后仍可连续播放。分集下标按过滤后的
  /// 可播放列表计算，避免伪协议分集让选中项偏移。
  void _play(FlutterMoviesPlaySource source, {FlutterMoviesPlayEpisode? from}) {
    final detail = _detail;
    if (detail == null) return;
    final all = FlutterMoviesStreamSources.of(source);
    if (all.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该线路暂无可播放地址')));
      return;
    }
    var index = 0;
    if (from != null) {
      final target = from.uri?.toString();
      final found = all.indexWhere((stream) => stream.url.toString() == target);
      if (found > 0) index = found;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaPlaybackPage(
          title: detail.title,
          sources: index == 0 ? all : all.sublist(index),
          historyId: 'fluttermovies.${detail.id}.${source.from}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    if (_loading && detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('影片详情')),
        body: const FlutterMoviesStatusView.loading(),
      );
    }
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('影片详情')),
        body: FlutterMoviesStatusView.error(
          _error ?? '影片详情加载失败',
          onRetry: _load,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(detail.title)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _header(detail),
          if (detail.introduction.isNotEmpty) _introduction(detail),
          _sourceSection(),
          _episodeSection(),
          if (detail.item.vodActor.isNotEmpty)
            _line('主演', detail.item.vodActor),
          if (detail.item.vodDirector.isNotEmpty)
            _line('导演', detail.item.vodDirector),
        ],
      ),
    );
  }

  Widget _header(FlutterMoviesVideoDetail detail) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 170,
          child: FlutterMoviesNetworkImage(
            imageUrl: widget.api.imageUrl(
              detail.item.primaryImage.isNotEmpty
                  ? detail.item.primaryImage
                  : detail.item.listImage,
            ),
            radius: 10,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in _tags(detail)) Chip(label: Text(tag)),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  List<String> _tags(FlutterMoviesVideoDetail detail) {
    final item = detail.item;
    return <String>[
      if (item.vodYear.isNotEmpty) item.vodYear,
      if (item.vodArea.isNotEmpty) item.vodArea,
      if (item.vodClass.isNotEmpty) item.vodClass,
      if (item.vodRemarks.isNotEmpty) item.vodRemarks,
      if (item.scoreLabel.isNotEmpty) '评分 ${item.scoreLabel}',
      if (item.vodDoubanScore.isNotEmpty) '豆瓣 ${item.vodDoubanScore}',
    ];
  }

  Widget _introduction(FlutterMoviesVideoDetail detail) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('简介', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          detail.introduction,
          maxLines: _introExpanded ? null : 3,
          overflow: _introExpanded ? null : TextOverflow.ellipsis,
        ),
        TextButton(
          onPressed: () => setState(() => _introExpanded = !_introExpanded),
          child: Text(_introExpanded ? '收起' : '展开'),
        ),
      ],
    ),
  );

  Widget _sourceSection() {
    if (_sources.isEmpty) {
      return const Padding(padding: EdgeInsets.all(12), child: Text('暂无播放线路'));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('播放线路', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < _sources.length; index++)
                ChoiceChip(
                  label: Text(_sources[index].label),
                  selected: index == _sourceIndex,
                  onSelected: (_) => _selectSource(index),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _episodeSection() {
    final source = _selectedSource;
    if (source == null) return const SizedBox.shrink();
    final episodes = source.episodes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '选集（${episodes.length}）',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: FlutterMoviesStreamSources.of(source).isEmpty
                    ? null
                    : () => _play(source),
                icon: const Icon(Icons.play_arrow),
                label: const Text('播放'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (episodes.isEmpty)
            const Text('该线路暂无分集地址')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < episodes.length; index++)
                  OutlinedButton(
                    onPressed: () {
                      final episode = episodes[index];
                      if (!episode.isPlayable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('该集暂无可播放地址')),
                        );
                        return;
                      }
                      _play(source, from: episode);
                    },
                    child: Text(episodes[index].label),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
    child: Text('$label：$value'),
  );
}
