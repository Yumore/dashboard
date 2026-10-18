import 'package:dashboard/features/movie/flutterdouban/flutterdouban_mock_request.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_page_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 条目详情 — the source's `detail_page.dart` flow (subject header, 简介, 影人,
/// 预告片, 短评, 长评).
///
/// Source quirk preserved: in mock mode the requested [subjectId] is ignored,
/// exactly like `API.getMovieDetail` returning `mock2("subject_26266893")`
/// (`lib/http/API.dart:139-145`, `lib/pages/detail/detail_page.dart:545`).
class FlutterDouBanSubjectPage extends StatefulWidget {
  const FlutterDouBanSubjectPage({
    super.key,
    required this.subjectId,
    this.title = '',
    this.useNetData = true,
    this.dio,
    this.assetLoader,
  });

  final String subjectId;
  final String title;
  final bool useNetData;
  final Dio? dio;
  final FlutterDouBanAssetLoader? assetLoader;

  @override
  State<FlutterDouBanSubjectPage> createState() =>
      FlutterDouBanSubjectPageState();
}
