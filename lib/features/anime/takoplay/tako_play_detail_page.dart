import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Tako-Play anime detail screen: summary, genres and the episode list.
class TakoPlayDetailPage extends StatefulWidget {
  const TakoPlayDetailPage({required this.anime, this.client, super.key});

  /// The card that was tapped; its URL drives the detail request.
  final TakoAnime anime;

  /// Injectable for tests; a default client is created and owned when null.
  final TakoPlayClient? client;

  @override
  State<TakoPlayDetailPage> createState() => TakoPlayDetailPageState();
}
