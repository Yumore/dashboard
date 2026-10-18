import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_list_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_tile.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';

/// State of [HakaSearchPage].
class HakaSearchPageState extends State<HakaSearchPage> {
  late final HakaSearchController _controller;
  final TextEditingController _input = TextEditingController();
  HakaComicListController? _results;

  @override
  void initState() {
    super.initState();
    _controller = HakaSearchController(
      repository: widget.repository,
      historyStore: widget.searchHistory,
    )
      ..loadHistory()
      ..loadHotWords();
  }

  @override
  void dispose() {
    _input.dispose();
    _controller.dispose();
    _results?.dispose();
    super.dispose();
  }

  Future<void> _submit(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    _input.text = trimmed;
    await _controller.record(trimmed);
    final next = HakaComicListController.search(
      repository: widget.repository,
      keyword: trimmed,
    );
    final previous = _results;
    setState(() => _results = next);
    previous?.dispose();
    await next.load();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _input,
            textInputAction: TextInputAction.search,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: '搜索漫画',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _input.clear();
                  final previous = _results;
                  setState(() => _results = null);
                  previous?.dispose();
                },
              ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: results == null
              ? _buildTerms()
              : ListenableBuilder(
                  listenable: results,
                  builder: (context, child) {
                    return HakaStateView<List<HakaComicBase>>(
                      state: results.state,
                      onRetry: () => results.load(refresh: true),
                      emptyMessage: '没有找到相关漫画',
                      builder: (context, comics) {
                        return ListView.builder(
                          itemCount: comics.length,
                          itemBuilder: (context, index) {
                            final comic = comics[index];
                            return HakaComicTile(
                              comic: comic,
                              onTap: () => widget.onOpenComic(comic.uid),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final history = _controller.history;
        final hot = _controller.hotWordsState.data ?? const <String>[];
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            if (history.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('搜索历史', style: Theme.of(context).textTheme.titleSmall),
                  TextButton(
                    onPressed: _controller.clearHistory,
                    child: const Text('清空'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final term in history)
                    InputChip(
                      label: Text(term),
                      onPressed: () => _submit(term),
                      onDeleted: () => _controller.removeHistory(term),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text('热门搜索', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_controller.hotWordsState.isLoading && hot.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_controller.hotWordsState.hasError)
              TextButton(
                onPressed: _controller.loadHotWords,
                child: const Text('热词加载失败，点击重试'),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final term in hot)
                    ActionChip(
                      label: Text(term),
                      onPressed: () => _submit(term),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}
