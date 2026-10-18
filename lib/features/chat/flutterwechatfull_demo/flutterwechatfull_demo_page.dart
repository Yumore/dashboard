import 'package:flutter/material.dart';

import 'flutterwechatfull_demo_page_state.dart';

/// Entry point of the ported flutterWeChat static demo.
///
/// The source app opens on `SplashPage` and, for an already-installed copy,
/// shows the full-screen ad carousel before the login screen. The host demo
/// starts on that same ad screen, then walks the source's real login flow into
/// the four-tab home shell (微信 / 通讯录 / 发现 / 我).
class FlutterWechatFullDemoPage extends StatefulWidget {
  const FlutterWechatFullDemoPage({super.key});

  @override
  State<FlutterWechatFullDemoPage> createState() =>
      FlutterWechatFullDemoPageState();
}
