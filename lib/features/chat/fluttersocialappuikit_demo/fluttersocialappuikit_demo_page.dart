import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_page_state.dart';

/// Entry page of the ported FlutterSocialAppUIKit demo
/// (source `lib/views/screens/auth/login.dart:13`, class `Login`).
///
/// The source's first screen is its authentication screen; the port keeps that
/// as the demo entry, and the `Submit` button replaces it with the tab shell
/// (`FlutterSocialAppUIKitMainPage`).
class FlutterSocialAppUIKitDemoPage extends StatefulWidget {
  const FlutterSocialAppUIKitDemoPage({super.key});

  @override
  State<FlutterSocialAppUIKitDemoPage> createState() =>
      FlutterSocialAppUIKitDemoPageState();
}
