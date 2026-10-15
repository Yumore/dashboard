import 'package:dashboard/views/novel/novel_home.dart';
import 'package:flutter/material.dart';

class NovelModulePage extends StatelessWidget {
  const NovelModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('小说')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const NovelHomePage()),
          ),
          icon: const Icon(Icons.auto_stories_outlined),
          label: const Text('打开小说库'),
        ),
      ),
    );
  }
}
