import 'package:dashboard/features/anime/animeone/animeone_schedule_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 新番表：按星期分页显示当季新番。
class AnimeOneSchedulePage extends StatefulWidget {
  const AnimeOneSchedulePage({this.client, this.watchStore, super.key});

  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneSchedulePage> createState() => AnimeOneSchedulePageState();
}
