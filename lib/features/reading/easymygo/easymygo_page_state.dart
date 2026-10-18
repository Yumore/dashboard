import 'package:dashboard/features/reading/easymygo/easymygo_page.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/service/reading_service.dart';
import 'package:dashboard/features/reading/easymygo/setting/source_setting_page.dart';
import 'package:dashboard/features/reading/easymygo/shelf/shelf_page.dart';
import 'package:dashboard/features/reading/easymygo/search/book_search_page.dart';
import 'package:flutter/material.dart';

class EasyMyGoPageState extends State<EasyMyGoPage> {
  ReadingService? _service;
  String? _error;
  bool _loading = true;

  LibraryStore get _library => widget.libraryStore ?? LibraryStore();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final injected = widget.service;
    if (injected != null) {
      setState(() {
        _service = injected;
        _loading = false;
      });
      return;
    }
    try {
      final service = await ReadingService.create();
      if (!mounted) return;
      setState(() {
        _service = service;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EasyMyGo 插件阅读')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text('书源引擎初始化失败\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _bootstrap();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    final service = _service!;
    final enabled = service.bundle.length;
    final total = service.allSources.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '已启用 $enabled / $total 个书源',
          key: const ValueKey('easymygo-source-summary'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            key: const ValueKey('easymygo-entry-shelf'),
            leading: const Icon(Icons.bookmarks_outlined),
            title: const Text('书架与历史'),
            subtitle: const Text('收藏、置顶、阅读进度与历史记录'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(
              ShelfPage(service: service, libraryStore: _library),
            ),
          ),
        ),
        Card(
          child: ListTile(
            key: const ValueKey('easymygo-entry-search'),
            leading: const Icon(Icons.search),
            title: const Text('搜索书源'),
            subtitle: const Text('按书源检索漫画 / 小说并加入书架'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(
              BookSearchPage(service: service, libraryStore: _library),
            ),
          ),
        ),
        Card(
          child: ListTile(
            key: const ValueKey('easymygo-entry-sources'),
            leading: const Icon(Icons.extension_outlined),
            title: const Text('书源管理'),
            subtitle: const Text('启用、排序与导入规则书源（JSON）'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(SourceSettingPage(service: service)),
          ),
        ),
      ],
    );
  }
}
