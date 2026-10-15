import 'package:dashboard/features/chat/lan_chat_controller.dart';
import 'package:dashboard/features/chat/lan_chat_thread_page_state.dart';
import 'package:flutter/material.dart';

class LanChatThreadPage extends StatefulWidget {
  const LanChatThreadPage({
    required this.controller,
    required this.peer,
    super.key,
  });

  final LanChatController controller;
  final String peer;

  @override
  State<LanChatThreadPage> createState() => LanChatThreadPageState();
}
