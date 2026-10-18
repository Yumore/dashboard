import 'package:dashboard/features/reading/easymygo/registry/source_config_wrapper.dart';
import 'package:dashboard/features/reading/easymygo/setting/source_setting_page.dart';
import 'package:flutter/material.dart';

class SourceSettingPageState extends State<SourceSettingPage> {
  final TextEditingController _manifest = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _manifest.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final manifest = _manifest.text.trim();
    if (manifest.isEmpty) return;
    setState(() => _busy = true);
    try {
      final info = await widget.service.importPackage(manifest);
      if (!mounted) return;
      _manifest.clear();
      _toast('已导入扩展包 ${info.label}');
    } catch (error) {
      if (!mounted) return;
      _toast('导入失败：$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _move(int index, int delta) async {
    final configs = widget.service.configs;
    final target = index + delta;
    if (target < 0 || target >= configs.length) return;
    final current = configs[index];
    final other = configs[target];
    setState(() => _busy = true);
    await widget.service.setOrder(current.identify, other.order);
    await widget.service.setOrder(other.identify, current.order);
    if (mounted) setState(() => _busy = false);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final wrappers = widget.service.bundle.getSourceConfigWrapperList();
    final sorted = <SourceConfigWrapper>[
      for (final identify in <String>[
        ...widget.service.configs.map((config) => config.identify),
      ])
        if (widget.service.sourceDataOf(identify) != null)
          SourceConfigWrapper(
            config: widget.service.configs.firstWhere(
              (config) => config.identify == identify,
            ),
            source: widget.service.sourceDataOf(identify)!,
          ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('书源管理')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: <Widget>[
          Text('书源（已启用 ${wrappers.length}）', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var index = 0; index < sorted.length; index++)
            _sourceTile(index, sorted[index]),
          const Divider(height: 32),
          Text('扩展包', style: Theme.of(context).textTheme.titleMedium),
          for (final extension in widget.service.extensions)
            ListTile(
              dense: true,
              leading: Icon(
                extension.isError ? Icons.error_outline : Icons.extension,
              ),
              title: Text(extension.info.label),
              subtitle: Text(
                extension.isError
                    ? extension.errorMsg
                    : '${extension.info.fromPackage} · v${extension.info.versionName} · '
                          '${extension.sources.length} 个书源',
              ),
            ),
          const SizedBox(height: 8),
          Text('导入规则书源（粘贴扩展包 JSON）', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          TextField(
            key: const ValueKey<String>('easymygo-import-input'),
            controller: _manifest,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '{"package": "...", "label": "...", "sources": [...]}',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey<String>('easymygo-import-submit'),
            onPressed: _busy ? null : _import,
            child: Text(_busy ? '处理中…' : '导入'),
          ),
        ],
      ),
    );
  }

  Widget _sourceTile(int index, SourceConfigWrapper wrapper) {
    final source = wrapper.source;
    final enabled = wrapper.config.enabled;
    return SwitchListTile(
      key: ValueKey<String>('easymygo-source-${source.source.identify}'),
      value: enabled && !source.isError,
      onChanged: source.isError
          ? null
          : (value) => widget.service.setEnabled(source.source.identify, value),
      title: Text(source.source.label),
      subtitle: Text(
        source.isError
            ? '加载失败：${source.errorMsg}'
            : '${source.source.type.name} · ${source.source.fromPackage} · 顺序 ${wrapper.config.order}',
      ),
      secondary: SizedBox(
        width: 80,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: '上移',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed: index == 0 ? null : () => _move(index, -1),
            ),
            IconButton(
              tooltip: '下移',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => _move(index, 1),
            ),
          ],
        ),
      ),
      isThreeLine: true,
    );
  }
}
