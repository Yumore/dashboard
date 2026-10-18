import 'package:dashboard/features/anime/animeone/animeone_detail_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 动画分类 / 剧集列表页：支持分页加载与单集播放。
class AnimeOneDetailPage extends StatefulWidget {
  const AnimeOneDetailPage({
    required this.link,
    this.title,
    this.seasonal,
    this.client,
    this.watchStore,
    super.key,
  });

  final String link;
  final String? title;

  /// 新番表入口进来的页面会显示每集的“全集 / 下一集”按钮。
  final bool? seasonal;
  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneDetailPage> createState() => AnimeOneDetailPageState();
}
