import 'package:dashboard/views/comic/comic_home.dart';
import 'package:dashboard/features/comic/u17_library_page.dart';
import 'package:flutter/material.dart';

class ComicModulePage extends StatelessWidget {
  const ComicModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('漫画')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('原有漫画库'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ComicHomePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark_outlined),
            title: const Text('有妖气漫画源'),
            subtitle: const Text('列表、搜索、章节与图片阅读'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const U17LibraryPage()),
            ),
          ),
        ],
      ),
    );
  }
}
