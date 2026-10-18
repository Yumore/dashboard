import 'package:dashboard/features/comic/picacomic/controllers/picacomic_explore_controller.dart';
import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_category_page.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_comic_tile.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_detail_page.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_home_page.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_search_page.dart';
import 'package:flutter/material.dart';

class PicacomicHomePageState extends State<PicacomicHomePage> {
  late final PicacomicExploreController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PicacomicExploreController();
    if (_controller.parts.isEmpty && !_controller.loading) {
      _controller.reload();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicaComic'),
        actions: [
          IconButton(
            onPressed: _controller.reload,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final source = _controller.source;
          if (source == null) {
            return const Center(child: Text('没有可用的漫画源'));
          }
          return Column(
            children: [
              _sourceSelector(source),
              _exploreSelector(),
              if (_controller.loading) const LinearProgressIndicator(minHeight: 2),
              if (_controller.error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _controller.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Expanded(child: _content(source)),
            ],
          );
        },
      ),
    );
  }

  Widget _sourceSelector(ComicSource source) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (var i = 0; i < _controller.sources.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_controller.sources[i].name),
                selected: _controller.sourceIndex == i,
                onSelected: (_) => _controller.selectSource(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _exploreSelector() {
    final pages = _controller.explorePages;
    if (pages.length <= 1) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (var i = 0; i < pages.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () => _controller.selectExplorePage(i),
                child: Text(pages[i].title),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(ComicSource source) {
    final parts = _controller.parts;
    if (parts.isEmpty) {
      return const Center(child: Text('暂无内容'));
    }
    if (parts.length == 1 && parts.first.viewMore == null) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 400) {
            _controller.loadMore();
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.58,
          ),
          itemCount: parts.first.comics.length,
          itemBuilder: (context, index) =>
              _tile(source, parts.first.comics[index]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: parts.length,
      itemBuilder: (context, index) {
        final part = parts[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      part.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (part.viewMore != null)
                    TextButton(
                      onPressed: () => _viewMore(source, part.viewMore!),
                      child: const Text('更多'),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: part.comics.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) => SizedBox(
                  width: 110,
                  child: _tile(source, part.comics[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tile(ComicSource source, BaseComic comic) {
    final headers = source.getThumbnailLoadingConfig?.call(comic.cover);
    final headerMap = headers?['headers'];
    return PicacomicComicTile(
      comic: comic,
      imageHeaders: headerMap is Map
          ? {
              for (final entry in headerMap.entries)
                '${entry.key}': '${entry.value}',
            }
          : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PicacomicDetailPage(
            sourceKey: source.key,
            comicId: comic.id,
            title: comic.title,
            cover: comic.cover,
          ),
        ),
      ),
    );
  }

  void _viewMore(ComicSource source, String viewMore) {
    if (viewMore.startsWith('category:')) {
      final body = viewMore.substring('category:'.length);
      final at = body.indexOf('@');
      final category = at >= 0 ? body.substring(0, at) : body;
      final param = at >= 0 ? body.substring(at + 1) : null;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PicacomicCategoryPage(
            sourceKey: source.key,
            initialCategory: category,
            initialParam: param,
          ),
        ),
      );
    } else if (viewMore.startsWith('search:')) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => PicacomicSearchPage(
            sourceKey: source.key,
            initialKeyword: viewMore.substring('search:'.length),
          ),
        ),
      );
    }
  }
}
