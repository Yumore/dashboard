import 'package:dashboard/features/reading/book/engine/book_source_engine.dart';
import 'package:dashboard/features/reading/book/model/book_source.dart';
import 'package:dashboard/features/reading/book/model/explore_kind.dart';
import 'package:dashboard/features/reading/book/model/search_book.dart';
import 'package:dashboard/features/reading/book/repository/source_repository.dart';
import 'package:dashboard/features/reading/book/util/book_log.dart';
import 'package:dashboard/features/reading/book/view/book_detail_page.dart';
import 'package:dashboard/features/reading/book/view/explore_page.dart';
import 'package:flutter/material.dart';

class ExplorePageState extends State<ExplorePage> {
  final BookSourceEngine _engine = BookSourceEngine();
  final SourceRepository _sources = SourceRepository.instance;

  List<BookSource> _available = const <BookSource>[];
  BookSource? _source;
  List<ExploreKind> _kinds = const <ExploreKind>[];
  ExploreKind? _kind;
  List<SearchBook> _results = const <SearchBook>[];
  bool _loading = true;
  bool _loadingResults = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final all = await _sources.getAll();
      final usable = all.where((s) => s.canExplore).toList();
      if (!mounted) return;
      setState(() {
        _available = usable;
        _loading = false;
        if (usable.isNotEmpty) {
          _source = usable.first;
          _kinds = parseExploreKinds(usable.first.exploreUrl);
          _kind = _kinds.isNotEmpty ? _kinds.first : null;
        }
      });
    } catch (e, st) {
      BookLog.e('Explore', 'load sources failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _load() async {
    final source = _source;
    final kind = _kind;
    if (source == null || kind == null) return;
    setState(() {
      _loadingResults = true;
      _error = null;
      _results = const <SearchBook>[];
    });
    try {
      final found = await _engine.explore(source, kind.url, page: 1);
      if (!mounted) return;
      setState(() {
        _results = found;
        _loadingResults = false;
      });
    } catch (e, st) {
      BookLog.e('Explore', 'explore failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loadingResults = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_available.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? '没有可用的发现书源（书源需同时启用 enabledExplore 且配置 exploreUrl）',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<BookSource>(
                  initialValue: _source,
                  decoration: const InputDecoration(
                    labelText: '书源',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _available
                      .map(
                        (s) => DropdownMenuItem<BookSource>(
                          value: s,
                          child: Text(
                            s.bookSourceName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _source = value;
                      _kinds = parseExploreKinds(value.exploreUrl);
                      _kind = _kinds.isNotEmpty ? _kinds.first : null;
                      _results = const <SearchBook>[];
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _kinds.isEmpty || _loadingResults ? null : _load,
                child: const Text('加载'),
              ),
            ],
          ),
        ),
        if (_kinds.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _kinds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final kind = _kinds[index];
                final selected = kind.url == _kind?.url;
                return Center(
                  child: ChoiceChip(
                    label: Text(kind.title),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _kind = kind;
                        _results = const <SearchBook>[];
                      });
                      _load();
                    },
                  ),
                );
              },
            ),
          ),
        if (_loadingResults) const LinearProgressIndicator(),
        Expanded(child: _buildResults()),
      ],
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
      return const Center(child: Text('选择一个分类后点击“加载”'));
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _results[index];
        final subtitle = <String>[
          if (book.author.isNotEmpty) book.author,
          if (book.kind.isNotEmpty) book.kind,
        ].join(' · ');
        return ListTile(
          title: Text(book.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: subtitle.isEmpty ? null : Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => BookDetailPage(searchBook: book),
            ),
          ),
        );
      },
    );
  }
}
