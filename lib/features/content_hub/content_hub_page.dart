import 'package:dashboard/features/anime/anime_module_page.dart';
import 'package:dashboard/features/chat/chat_module_page.dart';
import 'package:dashboard/features/comic/comic_module_page.dart';
import 'package:dashboard/features/crawler/crawler_module_page.dart';
import 'package:dashboard/features/live/live_module_page.dart';
import 'package:dashboard/features/movie/movie_module_page.dart';
import 'package:dashboard/features/novel/novel_module_page.dart';
import 'package:dashboard/features/reading/reading_module_page.dart';
import 'package:dashboard/features/shared/content_module_card.dart';
import 'package:flutter/material.dart';

class ContentHubPage extends StatelessWidget {
  const ContentHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('内容中心')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              '一个入口访问阅读、影音、社区与直播内容',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ContentModuleCard(
            title: '阅读',
            description: '书架、章节阅读与阅读偏好设置',
            icon: Icons.chrome_reader_mode_outlined,
            color: Colors.teal,
            onTap: () => _open(context, const ReadingModulePage()),
          ),
          ContentModuleCard(
            title: '小说',
            description: '分类、排行、更新与轻小说详情',
            icon: Icons.auto_stories_outlined,
            color: Colors.indigo,
            onTap: () => _open(context, const NovelModulePage()),
          ),
          ContentModuleCard(
            title: '动漫',
            description: '最近更新、目录、搜索和收藏入口',
            icon: Icons.animation_outlined,
            color: Colors.deepPurple,
            onTap: () => _open(context, const AnimeModulePage()),
          ),
          ContentModuleCard(
            title: '漫画',
            description: '推荐、分类、排行、下载与阅读进度',
            icon: Icons.menu_book_outlined,
            color: Colors.pink,
            onTap: () => _open(context, const ComicModulePage()),
          ),
          ContentModuleCard(
            title: '影视',
            description: '首页推荐、分类、搜索、详情和播放清单',
            icon: Icons.movie_outlined,
            color: Colors.orange,
            onTap: () => _open(context, const MovieModulePage()),
          ),
          ContentModuleCard(
            title: '聊天',
            description: '本地会话、局域网聊天与消息记录',
            icon: Icons.forum_outlined,
            color: Colors.green,
            onTap: () => _open(context, const ChatModulePage()),
          ),
          ContentModuleCard(
            title: '直播',
            description: '频道订阅、多线路播放和在线直播间',
            icon: Icons.live_tv_outlined,
            color: Colors.red,
            onTap: () => _open(context, const LiveModulePage()),
          ),
          ContentModuleCard(
            title: '爬虫',
            description: '网页链接采集、任务控制、日志和配置导出',
            icon: Icons.travel_explore,
            color: Colors.blueGrey,
            onTap: () => _open(context, const CrawlerModulePage()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
