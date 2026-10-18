import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_page_state.dart';
import 'package:flutter/material.dart';

/// Port of `UserPage` from `flutter_tiktok/lib/pages/userPage.dart`.
class FlutterTiktokProfilePage extends StatefulWidget {
  const FlutterTiktokProfilePage({
    this.isSelfPage = false,
    this.canPop = false,
    this.onPop,
    super.key,
  });

  final bool isSelfPage;
  final bool canPop;
  final VoidCallback? onPop;

  static const Key actionKey = Key('fluttertiktok_profile_action');
  static const Key moreKey = Key('fluttertiktok_profile_more');
  static const Key backKey = Key('fluttertiktok_profile_back');

  @override
  State<FlutterTiktokProfilePage> createState() =>
      FlutterTiktokProfilePageState();
}
