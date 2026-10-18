import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_detail_page_state.dart';
import 'package:flutter/material.dart';

/// 影片详情：简介 + 播放线路选择 + 分集入口。
class FlutterMoviesDetailPage extends StatefulWidget {
  const FlutterMoviesDetailPage({
    required this.api,
    required this.vodId,
    super.key,
  });

  final FlutterMoviesApi api;
  final int vodId;

  @override
  State<FlutterMoviesDetailPage> createState() =>
      FlutterMoviesDetailPageState();
}
