import 'package:dashboard/features/shared/ui/content_entry_section.dart';
import 'package:dashboard/features/novel/flutternovel/flutternovel_page.dart';
import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:dashboard/views/novel/novel_home.dart';
import 'package:flutter/material.dart';

/// Novel business entries: the local library and the network-novel reader.
final List<ContentEntrySection> novelEntryCatalog = [
  ContentEntrySection(
    title: '小说库',
    description: '本地书架与网络小说阅读',
    entries: [
      ContentEntry(
        id: 'novel-home',
        title: '打开小说库',
        subtitle: '分类、排行、详情、章节与阅读历史',
        icon: Icons.auto_stories_outlined,
        accent: ContentAccents.novel,
        builder: (_) => const NovelHomePage(),
      ),
      ContentEntry(
        id: 'flutternovel',
        title: '网络小说',
        subtitle: '书架 / 搜索 / 三种翻页动画',
        icon: Icons.import_contacts_outlined,
        accent: ContentAccents.novel,
        builder: (_) => const FlutterNovelPage(),
      ),
    ],
  ),
];
