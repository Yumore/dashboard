import 'package:dashboard/features/comic/manhuatai/manhuatai_category_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_tile.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_sort_item.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiCategoryPageState extends State<ManhuataiCategoryPage> {
  static const int _pageSize = 7;

  final List<ManhuataiSortItem> _comics = <ManhuataiSortItem>[];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _totalPage = 1;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _comics.clear();
      _page = 1;
    });
    try {
      final result = await widget.source.sortList(page: 1, size: _pageSize);
      if (!mounted) {
        return;
      }
      setState(() {
        _comics.addAll(result.data);
        _totalPage = result.page.totalPage;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPage) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final result = await widget.source.sortList(page: _page + 1, size: _pageSize);
      if (!mounted) {
        return;
      }
      setState(() {
        _page += 1;
        _totalPage = result.page.totalPage;
        _comics.addAll(result.data);
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ManhuataiStatusView(loading: true);
    }
    if (_error != null) {
      return ManhuataiStatusView(message: _error, onRetry: _loadFirstPage);
    }
    if (_comics.isEmpty) {
      return ManhuataiStatusView(message: '暂无分类内容', onRetry: _loadFirstPage);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 240) {
          _loadMore();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: _comics.length + 1,
        itemBuilder: (context, index) {
          if (index == _comics.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _page >= _totalPage
                    ? const Text('没有更多了')
                    : TextButton(
                        onPressed: _loadingMore ? null : _loadMore,
                        child: Text(_loadingMore ? '加载中…' : '加载更多'),
                      ),
              ),
            );
          }
          final comic = _comics[index];
          return ManhuataiComicTile(
            title: comic.comicName,
            subtitle: comic.lastChapterName,
            imageUrl: ManhuataiImageUrl.cover(comicId: comic.comicId),
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
      ),
    );
  }
}
