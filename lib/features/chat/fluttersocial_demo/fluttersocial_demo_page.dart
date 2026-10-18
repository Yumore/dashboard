import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_page_state.dart';
import 'package:flutter/material.dart';

/// Entry point of the ported flutter-social demo.
///
/// It is the source app's first screen (source `lib/main.dart` routed `/` to
/// `LandingPage`), so the source's real flow is preserved end to end:
/// landing → log in / sign up → tab shell → chat thread / user details.
class FlutterSocialDemoPage extends StatefulWidget {
  const FlutterSocialDemoPage({super.key});

  @override
  State<FlutterSocialDemoPage> createState() => FlutterSocialDemoPageState();
}
