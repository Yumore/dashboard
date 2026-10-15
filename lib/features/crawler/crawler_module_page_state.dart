import 'package:dashboard/features/crawler/crawl_config.dart';
import 'package:dashboard/features/crawler/crawl_config_store.dart';
import 'package:dashboard/features/crawler/crawl_task.dart';
import 'package:dashboard/features/crawler/crawl_task_page.dart';
import 'package:dashboard/features/crawler/crawler_module_page.dart';
import 'package:flutter/material.dart';

class CrawlerModulePageState extends State<CrawlerModulePage> {
  final _store = CrawlConfigStore();
  final _tasks = <CrawlTask>[];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final configs = await Future.wait(CrawlConfig.presets.map(_store.load));
      if (!mounted) return;
      setState(() {
        _tasks.addAll(configs.map((config) => CrawlTask(config)));
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final task in _tasks) {
      task.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('网页采集任务')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text('读取任务配置失败：$_error'))
        : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '仅采集您有权访问的网页。每次手动运行请求一个页面，不自动遍历、登录或绕过访问限制。退出本模块会取消任务。',
                ),
              ),
              for (final task in _tasks)
                AnimatedBuilder(
                  animation: task,
                  builder: (context, _) => Card(
                    child: ListTile(
                      title: Text(task.config.name),
                      subtitle: Text(
                        '${task.state.label} · ${task.items.length} 条结果 · ${task.logs.length} 条日志',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              CrawlTaskPage(task: task, store: _store),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
  );
}
