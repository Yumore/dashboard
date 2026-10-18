import 'package:dashboard/features/anime/animeone/animeone_latest_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 最近更新：anime1.me 首页侧栏的更新列表。
class AnimeOneLatestPage extends StatefulWidget {
  const AnimeOneLatestPage({this.client, this.watchStore, super.key});

  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneLatestPage> createState() => AnimeOneLatestPageState();
}
