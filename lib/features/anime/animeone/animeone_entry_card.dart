import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_playback_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 一集动画的卡片：标题、时间、进度与“全集 / 下一集”入口。
class AnimeOneEntryCard extends StatelessWidget {
  const AnimeOneEntryCard({
    super.key,
    required this.entry,
    this.showEpisode = false,
    this.client,
    this.watchStore,
    this.now,
  });

  final AnimeOneEntry entry;

  /// 单集页面显示“全集 / 下一集”按钮，分类列表不显示。
  final bool showEpisode;
  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  /// 注入当前时间以便测试“3天前”这类文案。
  final DateTime? now;

  void _play(BuildContext context, String link) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnimeOnePlaybackPage(
          link: link,
          title: entry.formattedName(),
          client: client,
          watchStore: watchStore,
        ),
      ),
    );
  }

  String _progressText() {
    final key = entry.link;
    if (key == null || key.isEmpty) return '';
    final watch = watchStore?.entryFor(key);
    if (watch == null) return '';
    return ' | ${watch.progressLabel}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = entry.formattedName() ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: entry.needPassword() || entry.link == null
            ? null
            : () => _play(context, entry.link!),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.enhancedDate(now ?? DateTime.now())}'
                '${_progressText()}',
                style: theme.textTheme.bodySmall,
              ),
              if (entry.needPassword())
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '暂无播放地址（可能需要密码）',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              if (showEpisode &&
                  (entry.allEpisodes != null || entry.hasNextEpisode()))
                Row(
                  children: [
                    if (entry.allEpisodes != null)
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => AnimeOneDetailPage(
                                link: entry.allEpisodes!,
                                client: client,
                                watchStore: watchStore,
                              ),
                            ),
                          );
                        },
                        child: const Text('全集'),
                      ),
                    if (entry.hasNextEpisode())
                      TextButton(
                        onPressed: () => _play(context, entry.nextEpisode!),
                        child: const Text('下一集'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
