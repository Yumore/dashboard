import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_home_page_state.dart';
import 'package:flutter/material.dart';

/// 今日看片首页：幻灯片 + 最近更新 + 各父类推荐。
class FlutterMoviesHomePage extends StatefulWidget {
  const FlutterMoviesHomePage({required this.api, super.key});

  final FlutterMoviesApi api;

  @override
  State<FlutterMoviesHomePage> createState() => FlutterMoviesHomePageState();
}
