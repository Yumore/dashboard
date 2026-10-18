import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_page_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 豆瓣电影 (FlutterDouBan) browse screen.
///
/// The source app's real browse flows — 影院热映 / 即将上映 / 豆瓣 Top250 /
/// 一周口碑榜 — with the same `useNetData` switch it hid inside
/// `MovieRepository` (`lib/repository/movie_repository.dart:44-49`), except
/// this host defaults that switch to the **real network** path and surfaces it
/// as an app-bar toggle.
///
/// Entry to mount from `movie_entry_catalog.dart`:
/// `FlutterDouBanPage()`.
class FlutterDouBanPage extends StatefulWidget {
  const FlutterDouBanPage({
    super.key,
    this.initialUseNetData,
    this.dio,
    this.assetLoader,
  });

  /// Overrides the persisted `useNetData` flag (used by widget tests).
  final bool? initialUseNetData;

  /// Injectable transport; a default `Dio` is built when null.
  final Dio? dio;

  /// Injectable fixture reader; `rootBundle` is used when null.
  final FlutterDouBanAssetLoader? assetLoader;

  @override
  State<FlutterDouBanPage> createState() => FlutterDouBanPageState();
}
