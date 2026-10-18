import 'package:dashboard/features/chat/chat_hub_body.dart';
import 'package:dashboard/features/chat/chat_hub_controller.dart';
import 'package:dashboard/features/chat/chat_thread_page.dart';
import 'package:dashboard/features/chat/lan_chat_page.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:dashboard/features/chat/chat_module_page.dart';
import 'package:dashboard/app/platform/app_platform.dart';
import 'package:flutter/material.dart';

class ChatModulePageState extends State<ChatModulePage> {
  final _controller = ChatHubController();
  final _conversationNameInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _conversationNameInput.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createConversation() async {
    final input = _conversationNameInput..clear();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新建本地会话'),
        content: TextField(
          controller: input,
          autofocus: true,
          decoration: const InputDecoration(labelText: '会话名称'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!AppPlatform.supportsSocket) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('当前平台不支持局域网聊天')),
                );
                return;
              }
              openContentPage<void>(
                dialogContext,
                (_) => const LanChatPage(),
              );
            },
            icon: const Icon(Icons.lan_outlined),
            tooltip: '局域网聊天',
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, input.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final conversation = await _controller.create(name);
    if (!mounted) return;
    openContentPage<void>(
      context,
      (_) => ChatThreadPage(conversation: conversation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModulePageScaffold(
      title: '聊天',
      actions: [
        IconButton(
          onPressed: _createConversation,
          icon: const Icon(Icons.add_comment_outlined),
          tooltip: '新建会话',
        ),
      ],
      body: ChatHubBody(controller: _controller),
    );
  }
}
