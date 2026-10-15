import 'package:dashboard/features/movie/movie_episode.dart';
import 'package:dashboard/features/movie/movie_episodes_page_state.dart';
import 'package:dashboard/features/movie/movie_item.dart';
import 'package:flutter/material.dart';

class MovieEpisodesPage extends StatefulWidget {
  const MovieEpisodesPage({required this.movie, required this.load, super.key});

  final MovieItem movie;
  final Future<List<MovieEpisode>> Function() load;

  @override
  State<MovieEpisodesPage> createState() => MovieEpisodesPageState();
}
