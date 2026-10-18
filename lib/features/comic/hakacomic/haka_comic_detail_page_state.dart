import 'package:flutter/material.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_detail_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_favorite_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_network_cover.dart';
import 'package:dashboard/features/comic/hakacomic/haka_reader_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';

/// State of [HakaComicDetailPage].
class HakaComicDetailPageState extends State<HakaComicDetailPage> {
  late final HakaComicDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HakaComicDetailController(
      repository: widget.repository,
      comicId: widget.comicId,
      readRecords: widget.records,
      history: widget.history,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openReader() async {
    final chapters = _controller.orderedChapters;
    if (chapters.isEmpty) return;
    final chapter = _controller.startChapter ?? chapters.first;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HakaReaderPage(
          repository: widget.repository,
          comicId: widget.comicId,
          chapters: chapters,
          readRecords: widget.records,
          initialOrder: chapter.order,
          initialPage: _controller.startPage,
        ),
      ),
    );
    await _controller.refreshRecord();
  }

  Future<void> _openChapter(HakaChapter chapter) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => HakaReaderPage(
          repository: widget.repository,
          comicId: widget.comicId,
          chapters: _controller.orderedChapters,
          readRecords: widget.records,
          initialOrder: chapter.order,
        ),
      ),
    );
    await _controller.refreshRecord();
  }

  Future<void> _toggleRemoteFavourite() async {
    final action = await _controller.toggleFavourite();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(action == null ? '操作失败' : '服务器返回: $action')),
    );
  }

  Future<void> _addToLocalFavourites(HakaComic comic) async {
    final added = await widget.favorites.addComic(
      HakaFavoriteStore.defaultFolderName,
      comic.toJson(),
      comic.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(added ? '已加入本地收藏' : '已在本地收藏中')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_controller.state.data?.title ?? '漫画详情')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return HakaStateView<HakaComic>(
            state: _controller.state,
            onRetry: _controller.load,
            builder: (context, comic) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HakaNetworkCover(
                      image: comic.thumb,
                      width: 110,
                      height: 148,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comic.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('作者: ${comic.author ?? comic.creator.name}'),
                          Text(
                            '${comic.finished ? '已完结' : '连载中'} · '
                            '${comic.epsCount} 话 · ${comic.pagesCount} 页',
                          ),
                          Text('浏览 ${comic.viewsCount} · 喜欢 ${comic.likesCount}'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in comic.tags)
                                Chip(
                                  label: Text(tag),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _openReader,
                      icon: const Icon(Icons.menu_book_outlined),
                      label: Text(
                        _controller.record == null ? '开始阅读' : '继续阅读',
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _controller.isTogglingFavourite
                          ? null
                          : _toggleRemoteFavourite,
                      icon: Icon(
                        _controller.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: const Text('远程收藏'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _addToLocalFavourites(comic),
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('本地收藏'),
                    ),
                  ],
                ),
                if (comic.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('简介', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(comic.description),
                ],
                const SizedBox(height: 16),
                Text(
                  '章节 (${_controller.chapters.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_controller.chaptersError != null)
                  TextButton(
                    onPressed: _controller.loadChapters,
                    child: const Text('章节加载失败，点击重试'),
                  ),
                for (final chapter in _controller.orderedChapters.reversed)
                  ListTile(
                    dense: true,
                    title: Text(chapter.title),
                    subtitle: Text('order ${chapter.order}'),
                    onTap: () => _openChapter(chapter),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
