import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_movie_grid.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_list.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_view.dart';
import 'package:flutter/material.dart';

/// 分页列表的通用呈现：下拉刷新 + 滚动到底自动加载下一页 + 页尾状态。
class FlutterMoviesPagedGridView extends StatelessWidget {
  const FlutterMoviesPagedGridView({
    required this.list,
    required this.imageUrl,
    required this.onTap,
    required this.onRefresh,
    required this.onLoadMore,
    required this.emptyMessage,
    this.header,
    this.footer,
    super.key,
  });

  final FlutterMoviesPagedList list;
  final String? Function(FlutterMoviesListItem item) imageUrl;
  final void Function(FlutterMoviesListItem item) onTap;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final String emptyMessage;

  /// 网格上方固定内容（例如搜索框、排行 Tab）。
  final Widget? header;

  /// 网格下方固定内容（例如加载更多）。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (!list.loadedOnce) return const FlutterMoviesStatusView.loading();
    if (list.items.isEmpty && list.error != null) {
      return FlutterMoviesStatusView.error(
        list.error!,
        onRetry: () => onRefresh(),
      );
    }
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 96),
            FlutterMoviesStatusView.empty(emptyMessage),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 400) onLoadMore();
          return false;
        },
        child: FlutterMoviesMovieGrid(
          items: list.items,
          imageUrl: imageUrl,
          onTap: onTap,
          header: header,
          footer: Column(children: [_pageFooter(context), ?footer]),
        ),
      ),
    );
  }

  Widget _pageFooter(BuildContext context) {
    if (list.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final error = list.error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(error, style: Theme.of(context).textTheme.bodySmall),
            TextButton(
              onPressed: () => onLoadMore(),
              child: const Text('加载更多'),
            ),
          ],
        ),
      );
    }
    if (!list.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('没有更多了', style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}
