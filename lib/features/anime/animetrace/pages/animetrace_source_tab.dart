import 'dart:async';

import 'package:dashboard/features/anime/animetrace/animetrace_ping_status.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_repository.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_source.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_source_store.dart';
import 'package:flutter/material.dart';

/// The source list: every registered site with its enabled switch, its
/// reachability probe (dio-timed, replacing the source app's `dart_ping`) and
/// its custom base URL.
class AnimeTraceSourceTab extends StatefulWidget {
  const AnimeTraceSourceTab({
    required this.repository,
    required this.sourceStore,
    required this.sources,
    required this.onSourcesChanged,
    super.key,
  });

  final AnimeTraceRepository repository;
  final AnimeTraceSourceStore sourceStore;
  final List<AnimeTraceSource> sources;
  final ValueChanged<List<AnimeTraceSource>> onSourcesChanged;

  @override
  State<AnimeTraceSourceTab> createState() => _AnimeTraceSourceTabState();
}

class _AnimeTraceSourceTabState extends State<AnimeTraceSourceTab> {
  late List<AnimeTraceSource> _sources = List<AnimeTraceSource>.of(
    widget.sources,
  );
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    // The first health check is started here, never in build.
    unawaited(_refreshHealth());
  }

  @override
  void didUpdateWidget(covariant AnimeTraceSourceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sources != widget.sources &&
        widget.sources.isNotEmpty &&
        !_refreshing) {
      _sources = List<AnimeTraceSource>.of(widget.sources);
    }
  }

  Future<void> _refreshHealth() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _sources = <AnimeTraceSource>[
        for (final source in _sources)
          source.copyWith(
            pingStatus: source.discard
                ? const AnimeTracePingStatus(needPing: false)
                : AnimeTracePingStatus.pingingStatus(),
          ),
      ];
    });
    final refreshed = await widget.repository.refreshHealth(_sources);
    if (!mounted) return;
    setState(() {
      _sources = refreshed;
      _refreshing = false;
    });
  }

  Future<void> _toggleAll() async {
    final active = _sources.where((source) => !source.discard).toList();
    final allEnabled = active.every((source) => source.enable);
    await widget.sourceStore.setAllEnabled(active, enable: !allEnabled);
    final reloaded = await widget.repository.loadSources();
    if (!mounted) return;
    setState(() => _sources = reloaded);
    widget.onSourcesChanged(reloaded);
  }

  Future<void> _toggleOne(AnimeTraceSource source, bool enable) async {
    await widget.sourceStore.setEnabled(source, enable);
    if (!mounted) return;
    setState(() {
      _sources = <AnimeTraceSource>[
        for (final item in _sources)
          item.climbId == source.climbId ? item.copyWith(enable: enable) : item,
      ];
    });
    widget.onSourcesChanged(_sources);
  }

  Future<void> _editBaseUrl(AnimeTraceSource source) async {
    final controller = TextEditingController(text: source.baseUrl);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${source.name} 自定义域名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '基础地址',
            hintText: 'https://example.com',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(''),
            child: const Text('恢复默认'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await widget.sourceStore.setCustomBaseUrl(source.climbId, value);
    final reloaded = await widget.repository.loadSources();
    if (!mounted) return;
    setState(() => _sources = reloaded);
    widget.onSourcesChanged(reloaded);
  }

  @override
  Widget build(BuildContext context) {
    final active = _sources.where((source) => !source.discard).toList();
    final allEnabled =
        active.isNotEmpty && active.every((source) => source.enable);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: _refreshing
                    ? null
                    : () => unawaited(_refreshHealth()),
                icon: const Icon(Icons.network_check),
                label: Text(_refreshing ? '测试中…' : '测试连通性'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => unawaited(_toggleAll()),
                icon: Icon(
                  allEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                ),
                label: Text(allEnabled ? '全部停用' : '全部启用'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _sources.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final source = _sources[index];
              return ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: _colorOf(source.pingStatus),
                ),
                title: Text(source.name),
                subtitle: Text(
                  <String>[
                    source.discard ? '无法使用' : source.pingStatus.label,
                    if (source.baseUrl.isNotEmpty) source.baseUrl,
                    if (source.comment.isNotEmpty) source.comment,
                  ].join('\n'),
                ),
                isThreeLine: true,
                onTap: source.discard
                    ? null
                    : () => unawaited(_editBaseUrl(source)),
                trailing: source.discard
                    ? null
                    : Switch(
                        value: source.enable,
                        onChanged: (value) =>
                            unawaited(_toggleOne(source, value)),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _colorOf(AnimeTracePingStatus status) {
    if (status.needPing || status.pinging) return Colors.grey;
    return status.connectable ? Colors.green : Colors.red;
  }
}
