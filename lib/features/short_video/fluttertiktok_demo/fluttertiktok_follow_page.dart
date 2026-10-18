import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_page_state.dart';
import 'package:flutter/material.dart';

/// Port of `FollowPage` from `flutter_tiktok/lib/pages/followPage.dart`.
class FlutterTiktokFollowPage extends StatefulWidget {
  const FlutterTiktokFollowPage({super.key});

  static const int itemCount = FlutterTiktokDemoConfig.followRowCount;

  @override
  State<FlutterTiktokFollowPage> createState() =>
      FlutterTiktokFollowPageState();
}
