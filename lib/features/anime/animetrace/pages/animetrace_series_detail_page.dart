import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_series_detail_page_state.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_anime_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_episode_note_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_history_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:flutter/material.dart';

/// Series detail: metadata, the episode list with watched state and notes, and
/// playback through the host's existing `MediaPlaybackPage`.
class AnimeTraceSeriesDetailPage extends StatefulWidget {
  const AnimeTraceSeriesDetailPage({
    required this.anime,
    required this.animeDao,
    required this.episodeNoteDao,
    required this.historyDao,
    required this.imageStore,
    required this.repository,
    required this.onChanged,
    super.key,
  });

  final AnimeTraceAnime anime;
  final AnimeTraceAnimeDao animeDao;
  final AnimeTraceEpisodeNoteDao episodeNoteDao;
  final AnimeTraceHistoryDao historyDao;
  final AnimeTraceImageStore imageStore;
  final AnimeTraceRepository repository;

  /// Called after a change other tabs must observe (history, notes, metadata).
  final VoidCallback onChanged;

  @override
  State<AnimeTraceSeriesDetailPage> createState() =>
      AnimeTraceSeriesDetailPageState();
}
