import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_category_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_list_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_tile.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';

/// State of [HakaCategoryPage]: first page on entry, scroll-triggered paging.
class HakaCategoryPageState extends State<HakaCategoryPage> {
  late final HakaComicListController _controller;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = HakaComicListController.category(
      repository: widget.repository,
      category: widget.category.id ?? widget.category.title,
    )..load();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
      _controller.loadMore();
    }
  }

  void _openComic(HakaComicBase comic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HakaComicDetailPage(
          repository: widget.repository,
          comicId: comic.uid,
          history: widget.history,
          favorites: widget.favorites,
          records: widget.records,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return HakaStateView<List<HakaComicBase>>(
            state: _controller.state,
            onRetry: () => _controller.load(refresh: true),
            emptyMessage: '该分类暂无漫画',
            builder: (context, comics) {
              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _controller.refresh,
                      child: ListView.builder(
                        controller: _scroll,
                        itemCount: comics.length,
                        itemBuilder: (context, index) {
                          final comic = comics[index];
                          return HakaComicTile(
                            comic: comic,
                            onTap: () => _openComic(comic),
                          );
                        },
                      ),
                    ),
                  ),
                  _CategoryFooter(
                    sort: _controller.sort,
                    pages: _controller.pages,
                    page: _controller.page,
                    hasMore: _controller.hasMore,
                    isLoadingMore: _controller.isLoadingMore,
                    moreError: _controller.moreError,
                    onLoadMore: _controller.loadMore,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Paging footer: sort label, page counter and the manual load-more trigger.
class _CategoryFooter extends StatelessWidget {
  const _CategoryFooter({
    required this.sort,
    required this.pages,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.moreError,
    required this.onLoadMore,
  });

  final HakaComicSortType sort;
  final int pages;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? moreError;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (moreError != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: TextButton(
          onPressed: onLoadMore,
          child: const Text('加载更多失败，点击重试'),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          '${sort.title} · 共 $page/$pages 页 · 已加载完',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: isLoadingMore
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(onPressed: onLoadMore, child: const Text('加载更多')),
    );
  }
}
