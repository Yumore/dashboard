import 'package:dashboard/features/shared/ui/content_entry_section.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_demo_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_demo_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_page.dart';
import 'package:dashboard/features/chat/flutterwechatfull_demo/flutterwechatfull_demo_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_page.dart';
import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_entry_card.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Secondary chat interface demos, shown together in one bottom sheet so they
/// do not compete with the real local conversations on the chat page.
final List<ContentEntry> chatMoreDemoEntries = [
  ContentEntry(
    id: 'fake-wechat',
    title: '微信本地界面演示',
    subtitle: '静态会话、通讯录与聊天详情',
    icon: Icons.chat_bubble_outline,
    accent: ContentAccents.chat,
    builder: (_) => const FakeWechatDemoPage(),
  ),
  ContentEntry(
    id: 'social-app-uikit',
    title: 'Chat App 本地界面演示',
    subtitle: '会话列表、故事卡片与个人页',
    icon: Icons.forum_outlined,
    accent: ContentAccents.chat,
    builder: (_) => const FlutterSocialAppUIKitDemoPage(),
  ),
  ContentEntry(
    id: 'flutter-wechat',
    title: '微信界面演示',
    subtitle: '单页微信界面与主题切换',
    icon: Icons.chat_outlined,
    accent: ContentAccents.chat,
    builder: (_) => const FlutterWechatDemoPage(),
  ),
  ContentEntry(
    id: 'flutter-wechat-full',
    title: '微信全量界面演示',
    subtitle: '完整微信界面：会话 / 通讯录 / 发现 / 我',
    icon: Icons.chat_bubble,
    accent: ContentAccents.chat,
    builder: (_) => const FlutterWechatFullDemoPage(),
  ),
];

/// Chat interface demos. The real conversation list stays on the page itself.
final List<ContentEntrySection> chatDemoCatalog = [
  ContentEntrySection(
    title: '本地界面演示',
    description: '离线静态界面，用于预览聊天交互样式',
    entries: [
      ContentEntry(
        id: 'messenger-demo',
        title: 'Messenger 本地界面',
        subtitle: '会话列表、聊天详情与联系人',
        icon: Icons.dashboard_customize_outlined,
        accent: ContentAccents.chat,
        tooltip: 'Messenger 本地界面演示',
        builder: (_) => const MessengerDemoPage(),
      ),
      ContentEntry(
        id: 'heart-string-demo',
        title: 'Heart String 本地界面',
        subtitle: '动态、发现与消息',
        icon: Icons.favorite,
        accent: ContentAccents.chat,
        tooltip: 'Heart String 本地界面演示',
        builder: (_) => const FlutterSocialDemoPage(),
      ),
      ContentEntry(
        id: 'more-demos',
        title: '更多本地界面演示',
        subtitle: '微信 / Chat App 界面演示',
        icon: Icons.auto_awesome_outlined,
        accent: ContentAccents.chat,
        onTap: (context) => showContentEntrySheet(
          context,
          title: '更多本地界面演示',
          entries: chatMoreDemoEntries,
        ),
      ),
    ],
  ),
];
