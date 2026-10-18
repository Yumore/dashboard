import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_search_page_state.dart';
import 'package:flutter/material.dart';

/// 搜索：`wd` 关键词 + 分页。
class FlutterMoviesSearchPage extends StatefulWidget {
  const FlutterMoviesSearchPage({required this.api, super.key});

  final FlutterMoviesApi api;

  @override
  State<FlutterMoviesSearchPage> createState() =>
      FlutterMoviesSearchPageState();
}
