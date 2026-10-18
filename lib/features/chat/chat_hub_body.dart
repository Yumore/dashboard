import 'package:dashboard/features/shared/ui/content_section_header.dart';
import 'package:dashboard/features/shared/ui/content_entry_section_view.dart';
import 'package:dashboard/features/chat/chat_conversation.dart';
import 'package:dashboard/features/chat/chat_entry_catalog.dart';
import 'package:dashboard/features/chat/chat_hub_controller.dart';
import 'package:dashboard/features/chat/chat_thread_page.dart';
import 'package:dashboard/features/shared/ui/content_navigation.dart';
import 'package:dashboard/features/shared/ui/content_row.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/features/shared/ui/module_page_scaffold.dart';
import 'package:flutter/material.dart';

/// Chat module body: interface demos first, then the real local conversations.
class ChatHubBody extends StatelessWidget {
  const ChatHubBody({required this.controller, super.key});

  final ChatHubController controller;

  void _openThread(BuildContext context, ChatConversation conversation) {
    openContentPage<void>(
      context,
      (_) => ChatThreadPage(conversation: conversation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final conversations = controller.conversations;
        return ListView(
          padding: ModulePageScaffold.pagePadding,
          children: [
            for (var index = 0; index < chatDemoCatalog.length; index++) ...[
              if (index > 0) const SizedBox(height: ContentSpacing.md),
              ContentEntrySectionView(section: chatDemoCatalog[index]),
            ],
            const SizedBox(height: ContentSpacing.lg),
            const ContentSectionHeader(
              title: '本地会话',
              description: '消息保存在本机，云 IM 需要服务配置',
            ),
            if (conversations.isEmpty)
              const Padding(
                padding: EdgeInsets.all(ContentSpacing.lg),
                child: Text('暂无会话。此处先支持本地消息；云 IM 需要服务配置。'),
              )
            else
              for (final conversation in conversations)
                ContentRow(
                  leading: CircleAvatar(
                    child: Text(conversation.name.characters.first),
                  ),
                  title: conversation.name,
                  onTap: () => _openThread(context, conversation),
                ),
          ],
        );
      },
    );
  }
}
