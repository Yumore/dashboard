import 'package:dashboard/features/reading/easymygo/detail/book_detail_page.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/library/library_store.dart';
import 'package:dashboard/features/reading/easymygo/registry/source_config_wrapper.dart';
import 'package:dashboard/features/reading/easymygo/search/book_search_page.dart';
import 'package:dashboard/features/reading/easymygo/widget/book_cover_view.dart';
import 'package:flutter/material.dart';

class BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _keyword = TextEditingController();

  late final List<SourceConfigWrapper> _sources;
  String? _identify;
  List<BookCover> _results = const <BookCover>[];
  String? _nextKey;
  String? _error;
  bool _loading = false;
  bool _searched = false;

  LibraryStore get _store => widget.libraryStore ?? LibraryStore();

  @override
  void initState() {
    super.initState();
    _sources = widget.service.bundle
        .getSourceConfigWrapperList()
        .where(
          (wrapper) =>
              widget.service.bundle.searchComponent(
                wrapper.info.type,
                wrapper.identify,
              ) !=
              null,
        )
        .toList();
    _identify = _sources.isEmpty ? null : _sources.first.identify;
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final identify = _identify;
    final keyword = _keyword.text.trim();
    if (identify == null) {
      setState(() => _error = '没有可用的搜索书源');
      return;
    }
    if (keyword.isEmpty) {
      setState(() => _error = '请输入关键字');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    final (payload, covers, nextKey) = await widget.service.search(
      identify,
      keyword,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (payload.isError) {
        _error = payload.errorMsg;
        _results = const <BookCover>[];
        _nextKey = null;
        return;
      }
      _results = covers;
      _nextKey = nextKey;
      if (covers.isEmpty) _error = '没有搜索到结果';
    });
  }

  Future<void> _loadMore() async {
    final identify = _identify;
    final key = _nextKey;
    if (identify == null || key == null || _loading) return;
    setState(() => _loading = true);
    final (payload, covers, nextKey) = await widget.service.searchMore(
      identify,
      key,
      _keyword.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (payload.isError) {
        _error = payload.errorMsg;
        return;
      }
      _results = <BookCover>[..._results, ...covers];
      _nextKey = nextKey;
    });
  }

  Future<void> _openDetail(BookCover cover) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookDetailPage(
          service: widget.service,
          cover: cover,
          libraryStore: _store,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _star(BookCover cover) async {
    await _store.setStarred(cover, true);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已加入书架：${cover.label}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索书源')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey<String>('easymygo-search-source'),
                    initialValue: _identify,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: '书源',
                      border: OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<String>>[
                      for (final wrapper in _sources)
                        DropdownMenuItem<String>(
                          value: wrapper.identify,
                          child: Text(
                            '${wrapper.info.label} (${wrapper.info.type.name})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _identify = value;
                      _results = const <BookCover>[];
                      _nextKey = null;
                      _error = null;
                      _searched = false;
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    key: const ValueKey<String>('easymygo-search-keyword'),
                    controller: _keyword,
                    decoration: const InputDecoration(hintText: '关键字'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey<String>('easymygo-search-submit'),
                  onPressed: _loading ? null : _search,
                  child: const Text('搜索'),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _buildResults(context)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final error = _error;
    if (error != null && _results.isEmpty) {
      return Center(
        child: Text(error, key: const ValueKey<String>('easymygo-search-error')),
      );
    }
    if (!_searched) {
      return const Center(child: Text('选择书源并输入关键字'));
    }
    return ListView.builder(
      key: const ValueKey<String>('easymygo-search-results'),
      itemCount: _results.length + (_nextKey == null ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= _results.length) {
          return Center(
            child: TextButton(
              onPressed: _loading ? null : _loadMore,
              child: const Text('加载更多'),
            ),
          );
        }
        final cover = _results[index];
        return ListTile(
          leading: BookCoverView(cover: cover),
          title: Text(cover.label),
          subtitle: Text(
            cover.intro.isEmpty ? cover.source : cover.intro,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: '加入书架',
            icon: const Icon(Icons.star_border),
            onPressed: () => _star(cover),
          ),
          onTap: () => _openDetail(cover),
        );
      },
    );
  }
}
