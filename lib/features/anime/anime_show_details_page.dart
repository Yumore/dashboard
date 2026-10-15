import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_favorite_store.dart';
import 'package:dashboard/features/anime/anime_watch_store.dart';
import 'package:dashboard/features/anime/anime_show_details_page_state.dart';
import 'package:flutter/material.dart';

class AnimeShowDetailsPage extends StatefulWidget {
  const AnimeShowDetailsPage({
    required this.show,
    required this.favorites,
    required this.history,
    required this.onChanged,
    super.key,
  });

  final AnimeShow show;
  final AnimeFavoriteStore favorites;
  final AnimeWatchStore history;
  final Future<void> Function() onChanged;

  @override
  State<AnimeShowDetailsPage> createState() => AnimeShowDetailsPageState();
}
