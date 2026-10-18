import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_page_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 搜索 — the source's `search_page.dart` flow (`/v2/movie/search?q=`).
///
/// The source's search page sorted hits by `year` descending
/// (`lib/pages/search/search_page.dart:36`) and showed `电影` / other subtype
/// labels; this port keeps that ordering via
/// [FlutterDouBanSearchResult.sortedByYear] and the same paging shape
/// (`start` / `count`) the douban search endpoint supports.
class FlutterDouBanSearchPage extends StatefulWidget {
  const FlutterDouBanSearchPage({
    super.key,
    this.useNetData = true,
    this.dio,
    this.assetLoader,
  });

  final bool useNetData;
  final Dio? dio;
  final FlutterDouBanAssetLoader? assetLoader;

  @override
  State<FlutterDouBanSearchPage> createState() =>
      FlutterDouBanSearchPageState();
}
