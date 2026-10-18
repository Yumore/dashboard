import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_genre_feed_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/genre/feedbooks_genre_page_state.dart';

/// 源工程 `GenreScreen`
/// （`lib/src/features/explore/presentation/ui/screens/genre_screen.dart`）的宿主移植。
///
/// 分类页 = 一个分类的完整书单，滚到底自动翻页。
class FeedbooksGenrePage extends StatefulWidget {
  const FeedbooksGenrePage({
    super.key,
    required this.title,
    required this.url,
    this.dio,
    this.controller,
  });

  final String title;

  /// 该分类的 feed 地址（来自 feed 里的 `link.href`，是绝对地址）。
  final String url;

  final Dio? dio;
  final FeedbooksGenreFeedController? controller;

  static Route<void> route({
    required String title,
    required String url,
    Dio? dio,
    FeedbooksGenreFeedController? controller,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksGenrePage(
        title: title,
        url: url,
        dio: dio,
        controller: controller,
      ),
    );
  }

  @override
  State<FeedbooksGenrePage> createState() => FeedbooksGenrePageState();
}
