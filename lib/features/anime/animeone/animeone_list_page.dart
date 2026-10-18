import 'package:dashboard/features/anime/animeone/animeone_list_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 动画总目录：快速筛选 + 关键字搜索。
class AnimeOneListPage extends StatefulWidget {
  const AnimeOneListPage({this.client, this.watchStore, super.key});

  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneListPage> createState() => AnimeOneListPageState();
}
