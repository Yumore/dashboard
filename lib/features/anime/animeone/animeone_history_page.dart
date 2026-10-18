import 'package:dashboard/features/anime/animeone/animeone_history_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 观看记录：本地保存的集数、进度与“继续观看”入口。
class AnimeOneHistoryPage extends StatefulWidget {
  const AnimeOneHistoryPage({this.client, this.watchStore, super.key});

  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneHistoryPage> createState() => AnimeOneHistoryPageState();
}
