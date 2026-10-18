import 'package:dashboard/features/live/easy_tv_live/easy_tv_source.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_page.dart';
import 'package:dashboard/features/live/easy_tv_live/easy_tv_source_store.dart';
import 'package:flutter/material.dart';

class EasyTvSourcePageState extends State<EasyTvSourcePage> {
  late final EasyTvSourceStore _store =
      widget.sourceStore ?? const EasyTvSourceStore();

  List<EasyTvSource> _sources = const <EasyTvSource>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sources = await _store.load();
    if (!mounted) return;
    setState(() {
      _sources = sources;
      _loading = false;
    });
  }

  Future<void> _persist(List<EasyTvSource> sources) async {
    await _store.save(sources);
    if (!mounted) return;
    setState(() => _sources = sources);
  }

  String _stamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} '
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }

  Future<String?> _askLink(String title, String initial) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: '订阅地址',
            hintText: 'http(s)://…/list.m3u',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result == null) return null;
    return result.trim();
  }

  Future<void> _addNetwork() async {
    final link = await _askLink('添加网络订阅', '');
    if (link == null) return;
    if (link.isEmpty) return;
    if (!link.startsWith('http')) {
      _toast('订阅地址必须以 http/https 开头');
      return;
    }
    final source = EasyTvSource(link: link, time: _stamp(), selected: true);
    await _persist(EasyTvSourceStore.add(_sources, source));
  }

  Future<void> _restoreDefault() async {
    final source = EasyTvSource(
      link: EasyTvSource.defaultLink,
      time: _stamp(),
      selected: true,
    );
    await _persist(EasyTvSourceStore.add(_sources, source));
  }

  Future<void> _edit(EasyTvSource source) async {
    if (source.isDefault) {
      _toast('默认公共源地址不可编辑');
      return;
    }
    final link = await _askLink('编辑订阅地址', source.link);
    if (link == null || link.isEmpty || link == source.link) return;
    if (!link.startsWith('http')) {
      _toast('订阅地址必须以 http/https 开头');
      return;
    }
    final updated = source.copyWith(link: link, time: _stamp());
    final sources = <EasyTvSource>[
      for (final item in _sources) item.link == source.link ? updated : item,
    ];
    await _persist(EasyTvSourceStore.select(sources, link));
  }

  Future<void> _select(EasyTvSource source) async {
    await _persist(EasyTvSourceStore.select(_sources, source.link));
  }

  Future<void> _delete(EasyTvSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除订阅'),
        content: Text('确定删除 ${source.displayLink}？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _persist(EasyTvSourceStore.remove(_sources, source.link));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅源'),
        actions: [
          TextButton(onPressed: _restoreDefault, child: const Text('恢复默认源')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNetwork,
        icon: const Icon(Icons.add_link),
        label: const Text('添加订阅源'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: _sources.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) => _sourceTile(_sources[index]),
            ),
    );
  }

  Widget _sourceTile(EasyTvSource source) {
    final badges = <String>[
      if (source.isDefault) '默认',
      if (source.local) '本地',
      if (source.selected) '使用中',
    ];
    return ListTile(
      title: Text(
        source.displayLink,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        <String>[
          if (source.time.isNotEmpty) source.time,
          ...badges,
        ].join(' · '),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'use':
              _select(source);
            case 'edit':
              _edit(source);
            case 'delete':
              _delete(source);
          }
        },
        itemBuilder: (context) => [
          if (!source.selected)
            const PopupMenuItem(value: 'use', child: Text('使用此源')),
          if (!source.isDefault)
            const PopupMenuItem(value: 'edit', child: Text('编辑地址')),
          const PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => _select(source),
    );
  }
}
