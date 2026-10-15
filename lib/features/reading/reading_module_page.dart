import 'package:dashboard/views/novel/novel_home.dart';
import 'package:dashboard/features/reading/reading_web_page.dart';
import 'package:dashboard/features/reading/dodu_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_demo_page.dart';
import 'package:flutter/material.dart';

class ReadingModulePage extends StatelessWidget {
  const ReadingModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('阅读')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('阅读入口', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('比乎阅读演示'),
              subtitle: const Text('关注、推荐、热榜与本地静态问答'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ZhihuDemoPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmarks_outlined),
              title: const Text('DoDu 书架'),
              subtitle: const Text('原工程的书架、书城、我的三栏'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const DoduPage())),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('网页章节阅读'),
              subtitle: const Text('加载章节、清理网页正文和自定义替换规则'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ReadingWebPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: const Text('进入书架与小说库'),
              subtitle: const Text('分类、详情、章节与阅读历史'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const NovelHomePage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune_outlined),
              title: const Text('阅读偏好'),
              subtitle: const Text('字体、背景、翻页和状态栏设置'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.of(context).pushNamed('/NovelReaderSettings'),
            ),
          ),
        ],
      ),
    );
  }
}
