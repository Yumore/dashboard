import 'package:dashboard/features/reading/zhihu_demo/zhihu_article_list_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_ask_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_hot_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_search_page.dart';
import 'package:flutter/material.dart';

class ZhihuHomePage extends StatelessWidget {
  const ZhihuHomePage({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Theme(
                      data: Theme.of(context),
                      child: const ZhihuSearchPage(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.search),
                label: const Text('坚果R1摄像头损坏'),
              ),
            ),
            IconButton(
              tooltip: '提问',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Theme(
                    data: Theme.of(context),
                    child: const ZhihuAskPage(),
                  ),
                ),
              ),
              icon: const Icon(Icons.border_color),
            ),
          ],
        ),
        bottom: const TabBar(
          tabs: [
            Tab(text: '关注'),
            Tab(text: '推荐'),
            Tab(text: '热榜'),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          ZhihuArticleListPage(follow: true),
          ZhihuArticleListPage(follow: false),
          ZhihuHotPage(),
        ],
      ),
    ),
  );
}
