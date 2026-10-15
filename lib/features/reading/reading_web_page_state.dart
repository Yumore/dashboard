import 'package:dashboard/features/reading/reading_web_page.dart';
import 'package:dashboard/features/reading/reading_web_source.dart';
import 'package:flutter/material.dart';

class ReadingWebPageState extends State<ReadingWebPage> {
  final _urlInput = TextEditingController();
  final _replaceInput = TextEditingController();
  final _source = ReadingWebSource();
  String? _content;
  String? _error;
  bool _loading = false;

  Future<void> _load() async {
    final url = Uri.tryParse(_urlInput.text.trim());
    if (url == null) {
      setState(() => _error = '请输入章节网址');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final content = await _source.load(
        url,
        replaceRule: _replaceInput.text.trim(),
      );
      if (mounted) setState(() => _content = content);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _urlInput.dispose();
    _replaceInput.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('网页章节阅读')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _urlInput,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: '章节网址'),
            onSubmitted: (_) => _load(),
          ),
          TextField(
            controller: _replaceInput,
            decoration: const InputDecoration(
              labelText: '清理规则（可选）',
              hintText: '正则##替换内容，多条用 && 分隔',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _load,
            child: Text(_loading ? '加载中…' : '读取章节'),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_content != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SelectableText(
                _content!,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.8),
              ),
            ),
        ],
      ),
    );
  }
}
