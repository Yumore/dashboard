import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_page.dart';
import 'package:dashboard/features/reading/eso/eso_reader_page.dart';
import 'package:dashboard/features/reading/eso/eso_rule.dart';
import 'package:dashboard/features/reading/eso/eso_rule_store.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/material.dart';

/// eso 入口页状态：书架、跨源搜索、书源导入与管理。
class EsoPageState extends State<EsoPage>
    with SingleTickerProviderStateMixin {
  final EsoRuleStore _ruleStore = EsoRuleStore();
  final EsoHistoryItemStore _historyStore = EsoHistoryItemStore();
  final TextEditingController _searchController = TextEditingController();

  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  List<EsoRule> _rules = <EsoRule>[];
  List<EsoSearchItem> _shelf = <EsoSearchItem>[];
  List<EsoSearchItem> _results = <EsoSearchItem>[];
  bool _loading = true;
  bool _searching = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    EsoApiManager.configure(_ruleStore);
    _reload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final rules = await _ruleStore.getAllRules();
    final shelf = await _historyStore.getAll();
    shelf.sort(
        (a, b) => (b.lastReadTime ?? 0).compareTo(a.lastReadTime ?? 0));
    if (!mounted) return;
    setState(() {
      _rules = rules;
      _shelf = shelf;
      _loading = false;
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;
    final enabled = _rules.where((rule) => rule.enableSearch).toList();
    if (enabled.isEmpty) {
      setState(() => _message = '没有可搜索的书源，先去「书源」导入');
      return;
    }
    setState(() {
      _searching = true;
      _message = null;
      _results = <EsoSearchItem>[];
    });
    final collected = <EsoSearchItem>[];
    for (final rule in enabled) {
      try {
        final list =
            await EsoApiManager.instance.search(rule.id, query, 1, 20);
        collected.addAll(list);
      } catch (e) {
        // 单个源失败不影响其它源（源实现同样逐个源吞异常）
      }
      if (!mounted) return;
      setState(() => _results = List<EsoSearchItem>.from(collected));
    }
    if (!mounted) return;
    setState(() {
      _searching = false;
      _message = collected.isEmpty ? '没有搜索到结果' : null;
    });
  }

  Future<void> _open(EsoSearchItem item) async {
    await _historyStore.insertOrUpdateHistoryItem(item);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EsoReaderPage(item: item)),
    );
    await _reload();
  }

  Future<void> _removeItem(EsoSearchItem item) async {
    await _historyStore.removeSearchItem(<int>{item.id});
    await _reload();
  }

  Future<void> _importSource() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入书源'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '粘贴书源 JSON 数组，或 eso:// 分享串',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    controller.dispose();
    final data = (text ?? '').trim();
    if (data.isEmpty) return;
    final ok = await _ruleStore.restore(data);
    if (!mounted) return;
    setState(() => _message = ok ? '导入成功' : '导入失败：内容不是书源');
    await _reload();
  }

  Future<void> _removeRule(EsoRule rule) async {
    await _ruleStore.remove(<String>{rule.id});
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('亦搜'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: '书架'),
            Tab(text: '搜索'),
            Tab(text: '书源'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildShelf(),
                _buildSearch(),
                _buildRules(),
              ],
            ),
    );
  }

  Widget _buildShelf() {
    if (_shelf.isEmpty) {
      return const Center(child: Text('书架是空的，去「搜索」找一本'));
    }
    return ListView.builder(
      itemCount: _shelf.length,
      itemBuilder: (context, index) {
        final item = _shelf[index];
        final chapter = item.chapter ?? '';
        final progress = item.chaptersCount ?? 0;
        final current = (item.durChapterIndex ?? 0) + 1;
        return ListTile(
          title: Text(item.name ?? ''),
          subtitle: Text(<String>[
            if ((item.author ?? '').isNotEmpty) item.author ?? '',
            if ((item.origin ?? '').isNotEmpty) item.origin ?? '',
            if (progress > 0) '$current/$progress 章',
            if ((chapter).isNotEmpty) chapter,
          ].join(' · ')),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeItem(item),
          ),
          onTap: () => _open(item),
        );
      },
    );
  }

  Widget _buildSearch() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: '书名或作者',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _searching ? null : _search,
                child: Text(_searching ? '搜索中' : '搜索'),
              ),
            ],
          ),
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(_message ?? ''),
          ),
        if (_searching) const LinearProgressIndicator(),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _results[index];
              return ListTile(
                title: Text(item.name ?? ''),
                subtitle: Text(<String>[
                  if ((item.author ?? '').isNotEmpty) item.author ?? '',
                  if ((item.chapter ?? '').isNotEmpty) item.chapter ?? '',
                  if ((item.description ?? '').isNotEmpty)
                    item.description ?? '',
                ].join(' · '), maxLines: 2),
                trailing: Text(item.origin ?? ''),
                onTap: () => _open(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRules() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              FilledButton.icon(
                onPressed: _importSource,
                icon: const Icon(Icons.add),
                label: const Text('导入书源'),
              ),
              const SizedBox(width: 12),
              Text('共 ${_rules.length} 个'),
            ],
          ),
        ),
        Expanded(
          child: _rules.isEmpty
              ? const Center(child: Text('还没有书源'))
              : ListView.builder(
                  itemCount: _rules.length,
                  itemBuilder: (context, index) {
                    final rule = _rules[index];
                    return ListTile(
                      title: Text(rule.name),
                      subtitle: Text(
                        <String>[
                          rule.ruleTypeName,
                          if (rule.group.isNotEmpty) rule.group,
                          if (rule.host.isNotEmpty) rule.host,
                        ].join(' · '),
                        maxLines: 1,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeRule(rule),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
