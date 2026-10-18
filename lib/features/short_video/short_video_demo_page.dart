import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_page.dart';
import 'package:dashboard/features/short_video/short_video_feed_page.dart';
import 'package:dashboard/features/short_video/short_video_layout_page.dart';
import 'package:dashboard/features/short_video/short_video_like_page.dart';
import 'package:flutter/material.dart';

class ShortVideoDemoPage extends StatelessWidget {
  const ShortVideoDemoPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('短视频交互演示')),
    body: ListView(
      children: [
        ListTile(
          title: const Text('双击点赞动画'),
          onTap: () => _open(context, const ShortVideoLikePage()),
        ),
        ListTile(
          title: const Text('关注 / 推荐布局'),
          onTap: () => _open(context, const ShortVideoLayoutPage()),
        ),
        ListTile(
          title: const Text('竖向视频列表'),
          onTap: () => _open(context, const ShortVideoFeedPage()),
        ),
        ListTile(
          leading: const Icon(Icons.music_video_outlined),
          title: const Text('TikTok 本地界面演示'),
          subtitle: const Text('推荐 / 关注 / 消息 / 我 · 点赞 / 评论 / 资料'),
          onTap: () => _open(context, const FlutterTiktokDemoPage()),
        ),
      ],
    ),
  );

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
