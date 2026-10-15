import 'package:dashboard/features/crawler/crawl_config_store.dart';
import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:dashboard/features/crawler/crawl_task_page_state.dart';
import 'package:flutter/material.dart';

class CrawlTaskPage extends StatefulWidget {
  const CrawlTaskPage({super.key, required this.task, required this.store});

  final CrawlTask task;
  final CrawlConfigStore store;

  @override
  State<CrawlTaskPage> createState() => CrawlTaskPageState();
}
