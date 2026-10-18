import 'package:dashboard/features/movie/fluttermovies/fluttermovies_page_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 今日看片（CMS / appapi.php）模块入口。
///
/// [dio] 可注入，便于测试或复用宿主已有的 Dio 实例；为空时自建。
class FlutterMoviesPage extends StatefulWidget {
  const FlutterMoviesPage({this.dio, super.key});

  final Dio? dio;

  @override
  State<FlutterMoviesPage> createState() => FlutterMoviesPageState();
}
