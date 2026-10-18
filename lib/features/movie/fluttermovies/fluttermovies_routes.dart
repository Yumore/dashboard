import 'package:dashboard/features/movie/fluttermovies/fluttermovies_api.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_detail_page.dart';
import 'package:flutter/material.dart';

/// 从任意列表进入影片详情。
class FlutterMoviesRoutes {
  const FlutterMoviesRoutes._();

  static Future<void> openDetail(
    BuildContext context, {
    required FlutterMoviesApi api,
    required int vodId,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => FlutterMoviesDetailPage(api: api, vodId: vodId),
    ),
  );
}
