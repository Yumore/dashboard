import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_info.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 动画目录里的一行：名称 + 集数 / 年份季度 / 字幕组。
class AnimeOneInfoCard extends StatelessWidget {
  const AnimeOneInfoCard({
    super.key,
    required this.info,
    required this.index,
    this.client,
    this.watchStore,
  });

  final AnimeOneInfo info;
  final int index;
  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  /// 目录里的中文元数据保持原样，只做缺省填充。
  String get _episode => (info.episode ?? '').isEmpty ? '連載中' : info.episode!;

  String get _season => '${info.year ?? ''}${info.season ?? ''}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: index % 2 == 0 ? scheme.surface : scheme.surfaceContainer,
      child: InkWell(
        onTap: info.link == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AnimeOneDetailPage(
                      link: info.link!,
                      title: info.name,
                      client: client,
                      watchStore: watchStore,
                    ),
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name ?? '未知名称',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _episode,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _season,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      info.subtitle ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
