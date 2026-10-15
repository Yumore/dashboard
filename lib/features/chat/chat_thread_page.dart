import 'package:dashboard/features/chat/chat_conversation.dart';
import 'package:dashboard/features/chat/chat_thread_page_state.dart';
import 'package:flutter/material.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({required this.conversation, super.key});

  final ChatConversation conversation;

  @override
  State<ChatThreadPage> createState() => ChatThreadPageState();
}
