import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_search_page_state.dart';
import 'package:flutter/material.dart';

/// Tako-Play list screen: recently updated gogoanime rows plus keyword search.
class TakoPlaySearchPage extends StatefulWidget {
  const TakoPlaySearchPage({this.client, super.key});

  /// Injectable for tests; a default client is created and owned when null.
  final TakoPlayClient? client;

  @override
  State<TakoPlaySearchPage> createState() => TakoPlaySearchPageState();
}
