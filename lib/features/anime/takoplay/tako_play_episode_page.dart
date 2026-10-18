import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_episode_page_state.dart';
import 'package:flutter/material.dart';

/// Tako-Play player screen: extracts the gogoplay stream of one episode and
/// feeds it to the host's [MediaPlaybackPage].
class TakoPlayEpisodePage extends StatefulWidget {
  const TakoPlayEpisodePage({
    required this.episode,
    this.title = '',
    this.client,
    super.key,
  });

  final TakoEpisode episode;

  /// Player title; falls back to `第N集` when empty.
  final String title;

  /// Injectable for tests; a default client is created and owned when null.
  final TakoPlayClient? client;

  @override
  State<TakoPlayEpisodePage> createState() => TakoPlayEpisodePageState();
}
