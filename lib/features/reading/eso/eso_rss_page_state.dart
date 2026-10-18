import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_rss_page.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

/// RSS 页状态：抓取当前条目正文、切换条目并写回阅读记录。
class EsoRssPageState extends State<EsoRssPage> {
  final EsoHistoryItemStore _historyStore = EsoHistoryItemStore();

  List<String> _html = <String>[];
  bool _loading = true;
  String? _error;

  EsoSearchItem get _item => widget.item;

  List<EsoChapterItem> get _chapters => _item.chapters ?? <EsoChapterItem>[];

  int get _index {
    if (_chapters.isEmpty) return 0;
    return (_item.durChapterIndex ?? 0).clamp(0, _chapters.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chapters = _chapters;
    if (chapters.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final content = await EsoApiManager.instance
          .getContent(_item.originTag, chapters[_index].url ?? '');
      if (!mounted) return;
      setState(() {
        _html = content;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _select(int index) async {
    if (index < 0 || index >= _chapters.length) return;
    _item.durChapterIndex = index;
    _item.durChapter = _chapters[index].name;
    _item.durContentIndex = 1;
    await _historyStore.insertOrUpdateHistoryItem(_item);
    await _load();
  }

  /// HTML → 纯文本：块级标签与 `<br>` 转换行，其余标签丢弃。
  static List<String> plainParagraphs(List<String> html) {
    final paragraphs = <String>[];
    for (final chunk in html) {
      final normalized = chunk
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'</(?:p|div|li|h\d)>', caseSensitive: false), '\n');
      final text = html_parser.parse(normalized).documentElement?.text ?? '';
      for (final line in text.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty) paragraphs.add(trimmed);
      }
    }
    return paragraphs;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _item.name ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          if (chapters.length > 1)
            PopupMenuButton<int>(
              icon: const Icon(Icons.list),
              tooltip: '条目',
              initialValue: _index,
              onSelected: _select,
              itemBuilder: (context) => <PopupMenuEntry<int>>[
                for (var i = 0; i < chapters.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Text(
                      chapters[i].name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _buildBody(chapters),
    );
  }

  Widget _buildBody(List<EsoChapterItem> chapters) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('解析失败：$error', textAlign: TextAlign.center),
        ),
      );
    }
    final paragraphs = plainParagraphs(_html);
    if (paragraphs.isEmpty) {
      return const Center(child: Text('没有内容'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: paragraphs.length + 1,
      itemBuilder: (context, index) {
        if (index == paragraphs.length) {
          if (_index + 1 >= chapters.length) return const SizedBox(height: 24);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton(
              onPressed: () => _select(_index + 1),
              child: Text('下一条：${chapters[_index + 1].name ?? ''}'),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(paragraphs[index], style: const TextStyle(height: 1.6)),
        );
      },
    );
  }
}
