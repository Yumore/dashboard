import 'dart:async';

import 'package:dashboard/features/crawler/crawl_exporter.dart';
import 'package:dashboard/features/crawler/crawl_html_parser.dart';
import 'package:dashboard/features/crawler/crawl_state.dart';
import 'package:dashboard/features/crawler/crawl_task_page.dart';
import 'package:dashboard/app/platform/app_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CrawlTaskPageState extends State<CrawlTaskPage> {
  late final TextEditingController _url;
  late final TextEditingController _selector;
  late String _encoding;
  bool _saving = false;
  final _exporter = CrawlExporter();

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.task.config.url);
    _selector = TextEditingController(text: widget.task.config.selector);
    _encoding = widget.task.config.encoding;
  }

  @override
  void dispose() {
    _url.dispose();
    _selector.dispose();
    super.dispose();
  }

  void _message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(value)));
    }
  }

  Future<void> _start() async {
    if (_saving || widget.task.active) return;
    setState(() => _saving = true);
    try {
      final config = widget.task.config.edited(
        url: _url.text,
        selector: _selector.text,
        encoding: _encoding,
      );
      if (!config.demo) CrawlHtmlParser().parse('', config, config.uri);
      await widget.store.save(config);
      if (!mounted) return;
      widget.task.config = config;
      unawaited(widget.task.start());
    } catch (error) {
      _message('无法启动：$error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export(String kind) async {
    if (!AppPlatform.supportsFileSystem) {
      _message('当前平台不支持导出到本地文件');
      return;
    }
    try {
      final file = await _exporter.save(widget.task, kind);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('已导出 JSON'),
          content: SelectableText(file.path),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (error) {
      _message('导出失败：$error');
    }
  }

  Future<void> _copy(String value) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      _message('已复制链接');
    } catch (error) {
      _message('复制失败：$error');
    }
  }

  Color _logColor(String level) => switch (level) {
    'error' => Colors.red,
    'warning' => Colors.orange,
    'debug' => Colors.blueGrey,
    'verbose' => Colors.purple,
    _ => Colors.blue,
  };

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.task,
    builder: (context, _) {
      final task = widget.task;
      return Scaffold(
        appBar: AppBar(
          title: Text(task.config.name),
          actions: [
            PopupMenuButton<String>(
              tooltip: '导出任务数据',
              onSelected: _export,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'config', child: Text('导出配置')),
                PopupMenuItem(value: 'logs', child: Text('导出日志')),
                PopupMenuItem(value: 'results', child: Text('导出结果')),
              ],
            ),
            IconButton(
              tooltip: '清空日志',
              onPressed: task.clearLogs,
              icon: const Icon(Icons.clear_all),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!task.config.demo) ...[
              TextField(
                controller: _url,
                enabled: !task.active && !_saving,
                decoration: const InputDecoration(labelText: '网页地址'),
              ),
              TextField(
                controller: _selector,
                enabled: !task.active && !_saving,
                decoration: const InputDecoration(labelText: 'CSS 选择器'),
              ),
              DropdownButton<String>(
                value: _encoding,
                items: [
                  for (final encoding in ['utf-8', 'gb2312', 'gbk'])
                    DropdownMenuItem(value: encoding, child: Text(encoding)),
                ],
                onChanged: task.active || _saving
                    ? null
                    : (value) => setState(() => _encoding = value!),
              ),
            ],
            Text('状态：${task.state.label}', key: const ValueKey('crawl-status')),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: task.active || _saving ? null : _start,
                  child: const Text('保存并开始'),
                ),
                if (task.state == CrawlState.running)
                  OutlinedButton(
                    onPressed: task.pause,
                    child: const Text('暂停'),
                  ),
                if (task.state == CrawlState.paused)
                  OutlinedButton(
                    onPressed: task.resume,
                    child: const Text('继续'),
                  ),
                OutlinedButton(
                  onPressed: task.active ? task.stop : null,
                  child: const Text('停止'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('采集结果（${task.items.length}）'),
            for (final item in task.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.url.toString()),
                trailing: IconButton(
                  tooltip: '复制链接',
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copy(item.url.toString()),
                ),
              ),
            const Divider(),
            Text('任务日志（${task.logs.length}）'),
            for (final log in task.logs.reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${log.time.toIso8601String()} [${log.level}] ${log.content}',
                  style: TextStyle(color: _logColor(log.level)),
                ),
              ),
          ],
        ),
      );
    },
  );
}
