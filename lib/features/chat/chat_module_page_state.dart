import 'package:dashboard/features/chat/chat_conversation.dart';
import 'package:dashboard/features/chat/chat_local_store.dart';
import 'package:dashboard/features/chat/chat_module_page.dart';
import 'package:dashboard/features/chat/chat_thread_page.dart';
import 'package:dashboard/features/chat/lan_chat_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_page.dart';
import 'package:flutter/material.dart';

class ChatModulePageState extends State<ChatModulePage> {
  final _store = ChatLocalStore();
  List<ChatConversation> _conversations = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final conversations = await _store.conversations();
    if (mounted) setState(() => _conversations = conversations);
  }

  Future<void> _create() async {
    final input = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建本地会话'),
        content: TextField(
          controller: input,
          autofocus: true,
          decoration: const InputDecoration(labelText: '会话名称'),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LanChatPage()),
            ),
            icon: const Icon(Icons.lan_outlined),
            tooltip: '局域网聊天',
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    input.dispose();
    if (name == null || name.isEmpty) return;
    final conversation = await _store.create(name);
    await _refresh();
    if (mounted) _open(conversation);
  }

  Future<void> _open(ChatConversation conversation) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatThreadPage(conversation: conversation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MessengerDemoPage(),
              ),
            ),
            icon: const Icon(Icons.dashboard_customize_outlined),
            tooltip: 'Messenger 本地界面演示',
          ),
          IconButton(
            onPressed: _create,
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: '新建会话',
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? const Center(child: Text('暂无会话。此处先支持本地消息；云 IM 需要服务配置。'))
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(conversation.name.characters.first),
                  ),
                  title: Text(conversation.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _open(conversation),
                );
              },
            ),
    );
  }
}
