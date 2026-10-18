import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_conversation_page_state.dart';

/// Chat thread of the FlutterSocialAppUIKit demo
/// (source `lib/views/screens/chat/conversation.dart:12`).
///
/// Every list row and group row opens this same thread, exactly like the
/// source: the screen owns no conversation identity, it always shows the ten
/// sample bubbles and a fixed participant.
class FlutterSocialAppUIKitConversationPage extends StatefulWidget {
  const FlutterSocialAppUIKitConversationPage({super.key});

  @override
  State<FlutterSocialAppUIKitConversationPage> createState() =>
      FlutterSocialAppUIKitConversationPageState();
}
