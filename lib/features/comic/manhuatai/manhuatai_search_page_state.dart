import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_hot_search.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_comic_data.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiSearchPageState extends State<ManhuataiSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<ManhuataiHotSearch> _hot = <ManhuataiHotSearch>[];
  List<String> _history = <String>[];
  List<ManhuataiSearchComicData> _results = <ManhuataiSearchComicData>[];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadExtras() async {
    final history = await widget.store.searchHistory();
    List<ManhuataiHotSearch> hot = <ManhuataiHotSearch>[];
    try {
      hot = await widget.source.hotSearch();
    } catch (_) {
      // Hot keywords are optional; the history still works.
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _history = history;
      _hot = hot;
    });
  }

  Future<void> _search(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _controller.text = trimmed;
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
    });
    await widget.store.rememberSearch(trimmed);
    try {
      final result = await widget.source.searchComic(trimmed);
      if (!mounted) {
        return;
      }
      setState(() {
        _results = result.data;
        _loading = false;
        _history = <String>[
          trimmed,
          ..._history.where((item) => item != trimmed),
        ];
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _results = <ManhuataiSearchComicData>[];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: '搜索漫画',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: _loading
          ? const ManhuataiStatusView(loading: true)
          : _searched
              ? _buildResults()
              : _buildLanding(),
    );
  }

  Widget _buildResults() {
    if (_error != null) {
      return ManhuataiStatusView(message: _error, onRetry: () => _search(_controller.text));
    }
    if (_results.isEmpty) {
      return const ManhuataiStatusView(message: '没有找到相关漫画');
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final comic = _results[index];
        return ManhuataiComicTile(
          title: comic.comicName,
          imageUrl: ManhuataiImageUrl.cover(comicId: comic.comicId),
          subtitle: '${comic.totalViewNum}',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ManhuataiDetailPage(
                  comicId: comic.comicId,
                  source: widget.source,
                  store: widget.store,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanding() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        if (_history.isNotEmpty) ...<Widget>[
          Row(
            children: <Widget>[
              Text('搜索历史', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await widget.store.clearSearchHistory();
                  await _loadExtras();
                },
                child: const Text('清空'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _history
                .map(
                  (keyword) => ActionChip(
                    label: Text(keyword),
                    onPressed: () => _search(keyword),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (_hot.isNotEmpty) ...<Widget>[
          Text('热门搜索', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _hot
                .map(
                  (item) => ActionChip(
                    label: Text(item.comicName),
                    onPressed: () => _search(item.comicName),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
