import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/pages/animetrace_episode_note_page_state.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_episode_note_dao.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_image_store.dart';
import 'package:flutter/material.dart';

/// Editor for one episode note (or the series' rating note when the episode is
/// episode `0`), including the locally stored images attached to it.
class AnimeTraceEpisodeNotePage extends StatefulWidget {
  const AnimeTraceEpisodeNotePage({
    required this.anime,
    required this.episode,
    required this.episodeNoteDao,
    required this.imageStore,
    super.key,
  });

  final AnimeTraceAnime anime;
  final AnimeTraceEpisode episode;
  final AnimeTraceEpisodeNoteDao episodeNoteDao;
  final AnimeTraceImageStore imageStore;

  @override
  State<AnimeTraceEpisodeNotePage> createState() =>
      AnimeTraceEpisodeNotePageState();
}
