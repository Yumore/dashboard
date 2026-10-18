import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category_page_state.dart';
import 'package:flutter/material.dart';

/// 分类浏览：父类 / 子类切换 + 分页列表。
class FlutterMoviesCategoryPage extends StatefulWidget {
  const FlutterMoviesCategoryPage({required this.api, super.key});

  final FlutterMoviesApi api;

  @override
  State<FlutterMoviesCategoryPage> createState() =>
      FlutterMoviesCategoryPageState();
}
