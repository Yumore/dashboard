import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_episode.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie_card.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_season.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// 影视详情页状态。
///
/// 源工程 `DetailPage`：`Api.getDetail(id)` 拿到 `resource` / `movie_items` /
/// `season_list` / `similar` / `comments_hot`，电影走 `MovieResWidget`（版本
/// 卡片），剧集走 `EpisodeWidget`（季切换 + 集号网格），底部是相似推荐
/// （`MoviesGridWidget`）。点任意条目进入 `ResInfoPage`，参数由各模型的
/// `resourceArguments` 生成。
class YyetsDetailPageState extends State<YyetsDetailPage> {
  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  YyetsDetail? _detail;
  bool _loading = true;
  String? _error;
  int _seasonIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ownedApi?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _api.getDetail(widget.movieId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _seasonIndex = 0;
        _loading = false;
      });
    } on YyetsException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: widget.title ?? widget.movieId),
      );
    } on Exception {
      // 分享失败（桌面端无实现等）不影响页面，源工程也是静默忽略。
    }
  }

  void _openResource({
    required String id,
    String itemId = '',
    String season = '',
    String episode = '',
    String? title,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => YyetsResourcePage(
          id: id,
          itemid: itemId,
          channel: _detail?.resource.channel ?? '',
          season: season,
          episode: episode,
          title: title,
          api: _api,
          launcher: widget.launcher,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '影视详情'),
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
            tooltip: '分享',
          ),
        ],
      ),
      body: _body(detail),
    );
  }

  Widget _body(YyetsDetail? detail) {
    if (detail == null || _loading || _error != null) {
      return YyetsStatusView(loading: _loading, error: _error, onRetry: _load);
    }
    final resource = detail.resource;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 110,
              height: 150,
              child: YyetsMovieCard(
                movie: YyetsMovie(
                  id: widget.movieId,
                  cnName: widget.title ?? '',
                  poster: resource.posterBig,
                ),
                showTitle: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title ?? resource.channelCn,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      YyetsTag(text: resource.levelLabel),
                      YyetsTag(text: resource.categoryLabel),
                      YyetsTag(text: resource.playStatus),
                      if (resource.zimuzu?.trim().isNotEmpty ?? false)
                        YyetsTag(text: resource.zimuzu!),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '评分：${resource.score.isEmpty ? '暂无' : resource.score}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (resource.content.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(resource.content, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        if (detail.isMovie)
          YyetsMovieItems(
            items: detail.movieItems,
            onTap: (item) => _openResource(
              id: resource.id.isEmpty ? widget.movieId : resource.id,
              itemId: item.name,
              title: '${widget.title ?? ''} ${item.number}'.trim(),
            ),
          )
        else
          YyetsSeasonEpisodes(
            seasons: detail.seasons,
            seasonIndex: _seasonIndex.clamp(0, detail.seasons.length - 1),
            onSeasonChanged: (index) => setState(() => _seasonIndex = index),
            onEpisodeTap: (season, episode) => _openResource(
              id: resource.id.isEmpty ? widget.movieId : resource.id,
              season: season.season,
              episode: episode.episode,
              title:
                  '${widget.title ?? ''} ${season.label} 第${episode.episode}集',
            ),
          ),
        if (detail.similar.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          Text('相似推荐', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: detail.similar.length,
              itemBuilder: (context, index) {
                final movie = detail.similar[index];
                return SizedBox(
                  width: 120,
                  child: YyetsMovieCard(
                    movie: movie,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => YyetsDetailPage(
                          movieId: movie.id,
                          title: movie.title,
                          api: _api,
                          launcher: widget.launcher,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          '热门评论（${detail.commentsCount}）',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final comment in detail.hotComments)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(comment.username),
            subtitle: Text(comment.content),
          ),
        if (detail.hotComments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('暂无热门评论'),
          ),
      ],
    );
  }
}

/// 小标签（源工程 `tagText` 的样式）。
class YyetsTag extends StatelessWidget {
  const YyetsTag({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

/// 电影版本列表（源工程 `MovieResWidget`）。
class YyetsMovieItems extends StatelessWidget {
  const YyetsMovieItems({super.key, required this.items, this.onTap});

  final List<YyetsResourceItem> items;
  final ValueChanged<YyetsResourceItem>? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const YyetsStatusView(emptyText: '暂无可用版本');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('播放 / 下载', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final item in items)
              ActionChip(
                label: Text(item.play ? '${item.number} · 边下边播' : item.number),
                onPressed: onTap == null ? null : () => onTap!(item),
              ),
          ],
        ),
      ],
    );
  }
}

/// 季切换 + 集号网格（源工程 `EpisodeWidget`）。
class YyetsSeasonEpisodes extends StatelessWidget {
  const YyetsSeasonEpisodes({
    super.key,
    required this.seasons,
    required this.seasonIndex,
    this.onSeasonChanged,
    this.onEpisodeTap,
  });

  final List<YyetsSeason> seasons;
  final int seasonIndex;
  final ValueChanged<int>? onSeasonChanged;
  final void Function(YyetsSeason season, YyetsEpisode episode)? onEpisodeTap;

  YyetsSeason? get _current => seasons.isEmpty
      ? null
      : seasons[seasonIndex.clamp(0, seasons.length - 1)];

  @override
  Widget build(BuildContext context) {
    final current = _current;
    if (current == null) {
      return const YyetsStatusView(emptyText: '暂无剧集');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (seasons.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seasons.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ChoiceChip(
                label: Text(seasons[index].label),
                selected: index == seasonIndex,
                onSelected: (_) => onSeasonChanged?.call(index),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final episode in current.episodes)
              _episodeChip(context, current, episode),
          ],
        ),
        if (current.episodes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('本季暂无剧集'),
          ),
      ],
    );
  }

  Widget _episodeChip(
    BuildContext context,
    YyetsSeason season,
    YyetsEpisode episode,
  ) {
    final enabled = episode.canOpen && onEpisodeTap != null;
    final label = episode.name.trim().isEmpty
        ? '第${episode.episode}集'
        : '第${episode.episode}集 ${episode.name}';
    final widget = ActionChip(
      label: Text(label),
      onPressed: enabled ? () => onEpisodeTap!(season, episode) : null,
    );
    return Tooltip(message: episode.playTimeLabel, child: widget);
  }
}
