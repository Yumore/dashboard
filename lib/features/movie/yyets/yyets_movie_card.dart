import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:flutter/material.dart';

/// 影视卡片（榜单 / 搜索结果 / 相似推荐共用）。
///
/// 源工程对应 `MoviesGridWidget` 里的 `_movieItem`：海报 + 片名，底部一排标签
/// （`tagText(score)` 等）。源工程对空海报走 `transparent_image`，这里用
/// `CachedNetworkImage` 的 errorWidget 兜底。
class YyetsMovieCard extends StatelessWidget {
  const YyetsMovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.tags = const <String>[],
    this.showTitle = true,
  });

  final YyetsMovie movie;

  /// 点击回调；为 null 时卡片不可点（纯展示）。
  final VoidCallback? onTap;

  /// 额外标签，默认取 `movie.searchTags`（源工程的 area/score/status/category）。
  final List<String> tags;

  final bool showTitle;

  List<String> get _effectiveTags =>
      tags.isNotEmpty ? tags : movie.searchTags.take(3).toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: movie.displayPoster,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ColoredBox(
                        color: Color(0x11000000),
                        child: Center(child: Icon(Icons.movie_outlined)),
                      ),
                      errorWidget: (context, url, error) => const ColoredBox(
                        color: Color(0x11000000),
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      ),
                    ),
                    if (movie.score.trim().isNotEmpty)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              movie.score,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (showTitle) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                movie.gridTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              if (_effectiveTags.isNotEmpty)
                Text(
                  _effectiveTags.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
