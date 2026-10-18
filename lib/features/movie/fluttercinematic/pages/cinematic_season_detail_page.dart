import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_tv_season.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_season_detail_page_state.dart';
import 'package:flutter/material.dart';

/// Port of the source `lib/pages/season_detail_page.dart`: a show season's
/// episode list, fetched from `tv/{showId}/season/{seasonNumber}`.
class CinematicSeasonDetailPage extends StatefulWidget {
  const CinematicSeasonDetailPage({
    required this.showId,
    required this.season,
    required this.showTitle,
    this.api,
    super.key,
  });

  final int showId;
  final CinematicTvSeason season;
  final String showTitle;
  final CinematicApi? api;

  @override
  State<CinematicSeasonDetailPage> createState() =>
      CinematicSeasonDetailPageState();
}
