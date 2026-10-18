import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_ranking_page_state.dart';
import 'package:flutter/material.dart';

/// 排行榜：父类切换 + 按月点击分页（order=vod_hits_month）。
class FlutterMoviesRankingPage extends StatefulWidget {
  const FlutterMoviesRankingPage({required this.api, super.key});

  final FlutterMoviesApi api;

  @override
  State<FlutterMoviesRankingPage> createState() =>
      FlutterMoviesRankingPageState();
}
