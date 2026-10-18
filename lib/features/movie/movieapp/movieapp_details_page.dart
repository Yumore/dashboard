import 'package:dashboard/features/movie/movieapp/movieapp_api.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_details_page_state.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';
import 'package:flutter/material.dart';

/// Real TMDb metadata + credits + trailer links for one movie or TV show.
class MovieAppDetailsPage extends StatefulWidget {
  const MovieAppDetailsPage({
    required this.movie,
    required this.api,
    super.key,
  });

  final MovieAppMovie movie;
  final MovieAppApi api;

  @override
  State<MovieAppDetailsPage> createState() => MovieAppDetailsPageState();
}
