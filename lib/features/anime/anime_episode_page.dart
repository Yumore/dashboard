import 'package:dashboard/features/anime/anime_episode_page_state.dart';
import 'package:flutter/material.dart';

class AnimeEpisodePage extends StatefulWidget {
  const AnimeEpisodePage({required this.url, super.key});

  final Uri url;

  @override
  State<AnimeEpisodePage> createState() => AnimeEpisodePageState();
}
