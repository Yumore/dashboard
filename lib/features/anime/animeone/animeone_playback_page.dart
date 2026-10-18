import 'package:dashboard/features/anime/animeone/animeone_playback_page_state.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';

/// 用宿主的媒体播放器播放 anime1.me 的一集动画。
class AnimeOnePlaybackPage extends StatefulWidget {
  const AnimeOnePlaybackPage({
    required this.link,
    this.title,
    this.previous,
    this.client,
    this.watchStore,
    super.key,
  });

  final String link;
  final String? title;
  final Uri? previous;
  final AnimeOneSiteClient? client;
  final AnimeOneWatchStore? watchStore;

  @override
  State<AnimeOnePlaybackPage> createState() => AnimeOnePlaybackPageState();
}
