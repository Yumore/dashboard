import 'package:dashboard/features/reading/flutterebook/presentation/controllers/feedbooks_home_feed_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/features/reading/flutterebook/presentation/pages/home/feedbooks_home_page_state.dart';

/// 源工程 `HomeScreenSmall`
/// （`lib/src/features/home/presentation/ui/screens/home_screen_small.dart`）的宿主移植。
///
/// 依赖通过构造函数注入（宿主约定）：不传时页面自己创建并在 dispose 时释放，
/// 传了就用注入的；测试里可以塞一个 `Dio` + 假适配器，或直接塞 controller。
class FeedbooksHomePage extends StatefulWidget {
  const FeedbooksHomePage({super.key, this.dio, this.controller});

  final Dio? dio;
  final FeedbooksHomeFeedController? controller;

  static Route<void> route({
    Dio? dio,
    FeedbooksHomeFeedController? controller,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => FeedbooksHomePage(dio: dio, controller: controller),
    );
  }

  @override
  State<FeedbooksHomePage> createState() => FeedbooksHomePageState();
}
