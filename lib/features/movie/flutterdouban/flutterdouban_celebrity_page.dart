import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_page_state.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 影人 / 演职员详情 — the source's `person_detail_page.dart` flow.
///
/// In mock mode the ported `mock/celebrity.json` fixture is returned whatever
/// [celebrityId] is asked for; the source had no mock celebrity path at all
/// (`API.searchCelebrity` was network-only), so this is a host addition.
class FlutterDouBanCelebrityPage extends StatefulWidget {
  const FlutterDouBanCelebrityPage({
    super.key,
    required this.celebrityId,
    this.name = '',
    this.useNetData = true,
    this.dio,
    this.assetLoader,
  });

  final String celebrityId;
  final String name;
  final bool useNetData;
  final Dio? dio;
  final FlutterDouBanAssetLoader? assetLoader;

  @override
  State<FlutterDouBanCelebrityPage> createState() =>
      FlutterDouBanCelebrityPageState();
}
