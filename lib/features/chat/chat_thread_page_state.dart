import 'package:dashboard/features/chat/chat_local_store.dart';
import 'package:dashboard/features/chat/chat_message.dart';
import 'package:dashboard/features/chat/chat_thread_page.dart';
import 'package:flutter/material.dart';

class ChatThreadPageState extends State<ChatThreadPage> {
  final _store = ChatLocalStore();
  final _input = TextEditingController();
  List<ChatMessage> _messages = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final messages = await _store.messages(widget.conversation.id);
    if (mounted) setState(() => _messages = messages);
  }

  Future<void> _send() async {
    final content = _input.text.trim();
    if (content.isEmpty) return;
    await _store.send(widget.conversation.id, content);
    _input.clear();
    await _refresh();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: Alignment.centerRight,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message.content),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(hintText: '输入本地消息'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
