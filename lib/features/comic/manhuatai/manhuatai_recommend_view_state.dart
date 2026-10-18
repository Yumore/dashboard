import 'package:dashboard/features/comic/manhuatai/manhuatai_book_list.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_book_section_merge.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_book_section_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_recommend_view.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiRecommendViewState extends State<ManhuataiRecommendView> {
  bool _loading = true;
  String? _error;
  ManhuataiBookList _bookList = ManhuataiBookList.empty;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final legacy = await widget.source.legacyRecommend();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookList = legacy;
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
    if (_loadingMore) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final next = await widget.source.recommend(page: 2);
      if (!mounted) {
        return;
      }
      setState(() {
        _bookList = ManhuataiBookList(
          data:
              ManhuataiBookSectionMerge.merge(_bookList.data, next.data),
          status: next.status,
          message: next.message,
        );
      });
    } catch (_) {
      // Keep the already visible sections when the extra page fails.
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _openComic(ManhuataiComic comic) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManhuataiDetailPage(
          comicId: comic.comicId,
          source: widget.source,
          store: widget.store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ManhuataiStatusView(loading: true);
    }
    if (_error != null) {
      return ManhuataiStatusView(message: _error, onRetry: _load);
    }
    final books = _bookList.data.book;
    if (books.isEmpty) {
      return ManhuataiStatusView(message: '暂无推荐', onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: books.length + 1,
        itemBuilder: (context, index) {
          if (index == books.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : OutlinedButton(
                        onPressed: _loadMore,
                        child: const Text('加载更多'),
                      ),
              ),
            );
          }
          return ManhuataiBookSectionView(
            book: books[index],
            onOpenComic: _openComic,
          );
        },
      ),
    );
  }
}
