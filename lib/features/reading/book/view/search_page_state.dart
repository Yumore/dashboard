import 'package:dashboard/features/reading/book/model/search_book.dart';
import 'package:dashboard/features/reading/book/engine/book_source_engine.dart';
import 'package:dashboard/features/reading/book/repository/source_repository.dart';
import 'package:dashboard/features/reading/book/util/book_log.dart';
import 'package:dashboard/features/reading/book/view/book_detail_page.dart';
import 'package:dashboard/features/reading/book/view/search_page.dart';
import 'package:flutter/material.dart';

class SearchPageState extends State<SearchPage> {
  final BookSourceEngine _engine = BookSourceEngine();
  final SourceRepository _sources = SourceRepository.instance;
  final TextEditingController _controller = TextEditingController();

  List<SearchBook> _results = const <SearchBook>[];
  bool _searching = false;
  bool _done = false;
  String? _error;
  String _keyword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _done = false;
      _error = null;
      _results = const <SearchBook>[];
      _keyword = key;
    });

    final all = <SearchBook>[];
    final failures = <String>[];
    try {
      final sources = await _sources.getEnabled();
      var usable = 0;
      for (final source in sources) {
        if (!source.enabled || source.searchUrl.trim().isEmpty) continue;
        usable++;
        try {
          final found = await _engine.search(source, key, 1);
          all.addAll(found);
        } catch (e, st) {
          BookLog.e(
            'Search',
            'source ${source.bookSourceName} failed',
            error: e,
            stackTrace: st,
          );
          failures.add(source.bookSourceName);
        }
      }
      if (usable == 0) {
        if (!mounted) return;
        setState(() {
          _searching = false;
          _done = true;
          _error = '没有可用的搜索书源，请先在书源管理中导入书源';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _results = all;
        _searching = false;
        _done = true;
        if (all.isEmpty && failures.isNotEmpty) {
          _error = '搜索失败：${failures.join('、')}';
        }
      });
    } catch (e, st) {
      BookLog.e('Search', 'search failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _searching = false;
        _done = true;
        _error = '$e';
      });
    }
  }

  void _openDetail(SearchBook book) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BookDetailPage(searchBook: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索书籍')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      hintText: '书名 / 作者',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _searching ? null : _search,
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          if (_searching) const LinearProgressIndicator(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Text(
          _done ? '没有找到《$_keyword》' : '输入书名或作者后开始搜索',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _results[index];
        final subtitle = <String>[
          if (book.author.isNotEmpty) book.author,
          if (book.kind.isNotEmpty) book.kind,
          if (book.lastChapter.isNotEmpty) '最新：${book.lastChapter}',
        ].join(' · ');
        return ListTile(
          title: Text(book.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${book.sourceName}\n$subtitle',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: subtitle.isNotEmpty,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openDetail(book),
        );
      },
    );
  }
}
