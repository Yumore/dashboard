import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chats_page_state.dart';

/// `Chats` tab of the FlutterSocialAppUIKit demo
/// (source `lib/views/screens/chat/chats.dart:11`).
///
/// Two sub-tabs, `Message` and `Groups`, each a thirteen-row list that opens
/// the same chat thread. The source keeps the tab alive when switching the
/// outer page view (`AutomaticKeepAliveClientMixin`), which the port keeps.
class FlutterSocialAppUIKitChatsPage extends StatefulWidget {
  const FlutterSocialAppUIKitChatsPage({super.key});

  @override
  State<FlutterSocialAppUIKitChatsPage> createState() =>
      FlutterSocialAppUIKitChatsPageState();
}
