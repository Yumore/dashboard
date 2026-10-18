import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_feeds_page_state.dart';

/// `Home` tab of the FlutterSocialAppUIKit demo, titled `Feeds`
/// (source `lib/views/screens/home.dart:9`).
///
/// Thirteen cards, a search/filter icon in the app bar and an add button that
/// are both dead ends in the source (`onPressed: () {}`). Those stay dead.
class FlutterSocialAppUIKitFeedsPage extends StatefulWidget {
  const FlutterSocialAppUIKitFeedsPage({super.key});

  @override
  State<FlutterSocialAppUIKitFeedsPage> createState() =>
      FlutterSocialAppUIKitFeedsPageState();
}
