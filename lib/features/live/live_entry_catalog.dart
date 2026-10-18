import 'package:dashboard/features/shared/ui/content_entry_section.dart';
import 'package:dashboard/features/live/billd_live_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_page.dart';
import 'package:dashboard/features/live/my_tv/my_tv_page.dart';
import 'package:dashboard/features/shared/ui/content_entry.dart';
import 'package:dashboard/features/shared/ui/content_tokens.dart';
import 'package:flutter/material.dart';

/// Live-streaming sites. Subscription channels stay on the page itself.
final List<ContentEntrySection> liveEntryCatalog = [
  ContentEntrySection(
    title: '直播站点',
    description: '在线直播间与 IPTV 订阅源',
    entries: [
      ContentEntry(
        id: 'billd-live',
        title: 'Billd 直播',
        subtitle: '查看在线直播间',
        icon: Icons.live_tv,
        accent: ContentAccents.live,
        builder: (_) => const BilldLivePage(),
      ),
      ContentEntry(
        id: 'my-tv',
        title: '我的电视',
        subtitle: 'IPTV 直播源 · 分组换台 · XMLTV 节目单',
        icon: Icons.live_tv,
        accent: ContentAccents.live,
        builder: (_) => const MyTvPage(),
      ),
      ContentEntry(
        id: 'easy-tv',
        title: 'EasyTV 直播',
        subtitle: 'm3u/txt 订阅 · 线路失败切换 · 源管理',
        icon: Icons.live_tv_outlined,
        accent: ContentAccents.live,
        builder: (_) => const EasyTvPage(),
      ),
    ],
  ),
];
