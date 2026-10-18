import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_home_feed_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/explore/feedbooks_explore_page_state.dart';

/// 源工程 `ExploreScreenSmall`
/// （`lib/src/features/explore/presentation/ui/screens/explore_screen_small.dart`）的宿主移植。
class FeedbooksExplorePage extends StatefulWidget {
  const FeedbooksExplorePage({super.key, this.dio, this.controller});

  final Dio? dio;

  /// 源工程 Explore 页与首页共用同一个 popular feed provider，这里同样复用
  /// [FeedbooksHomeFeedController]。
  final FeedbooksHomeFeedController? controller;

  static Route<void> route({
    Dio? dio,
    FeedbooksHomeFeedController? controller,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksExplorePage(dio: dio, controller: controller),
    );
  }

  @override
  State<FeedbooksExplorePage> createState() => FeedbooksExplorePageState();
}
