import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_page_state.dart';
import 'package:flutter/material.dart';

/// Static Demo port of the `flutter_tiktok` app shell.
///
/// Screens: home feed, follow feed, messages, self profile, search drawer,
/// other-user profile drawer, camera page and profile detail page. All data is
/// the source's hard-coded sample data; remote sample videos are never played.
class FlutterTiktokDemoPage extends StatefulWidget {
  const FlutterTiktokDemoPage({super.key});

  @override
  State<FlutterTiktokDemoPage> createState() => FlutterTiktokDemoPageState();
}
