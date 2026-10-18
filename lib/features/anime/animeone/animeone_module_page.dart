import 'package:dashboard/features/anime/animeone/animeone_module_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// anime1.me 模块首页：入口卡片 + 继续观看。
class AnimeOneModulePage extends StatefulWidget {
  const AnimeOneModulePage({this.client, this.watchStore, super.key});

  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOneModulePage> createState() => AnimeOneModulePageState();
}
