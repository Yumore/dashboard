import 'package:dashboard/features/movie/dytt/dytt_detail_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_controller.dart';
import 'package:dashboard/features/movie/dytt/dytt_list_page.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_tile.dart';
import 'package:dashboard/features/movie/dytt/dytt_signing_notice.dart';
import 'package:flutter/material.dart';

/// 源工程 `ListPageState`：进入即取第 1 页，下拉刷新，滚动加载。
///
/// 源站不返回总页数，只有返回空页才停止翻页。
class DyttListPageState extends State<DyttListPage> {
  late final DyttListController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = DyttListController(
      api: widget.api,
      categoryId: widget.category.categoryId,
    )..addListener(_onChanged);
    _scrollController = ScrollController()..addListener(_onScroll);
    // 签名不可用时一个请求都不发，避免把空 key 当成签名送给源站。
    if (widget.api.signingSupported) _controller.load();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 400) {
      _controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _refresh() => _controller.load(refresh: true);

  void _open(DyttMovieDetail movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DyttDetailPage(api: widget.api, movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.api.signingSupported
        ? _listBody()
        : ListView(
            children: const [
              DyttSigningNotice(),
              SizedBox(height: 32),
              Center(child: Text('签名不可用，未请求电影天堂接口')),
            ],
          );
    // 单独使用时（没有外层 Scaffold）也要有 Material 祖先，ListTile 需要它。
    if (!widget.showAppBar) {
      return Material(type: MaterialType.transparency, child: body);
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: body,
    );
  }

  Widget _listBody() {
    final items = _controller.items;
    if (_controller.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _controller.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _controller.load(refresh: true),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('该分类暂无内容')),
          ],
        ),
      );
    }
    final showFooter = _controller.hasMore || _controller.isLoadingMore;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: items.length + (showFooter ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: _controller.isLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: _controller.loadMore,
                        child: Text(_controller.moreError ?? '加载更多'),
                      ),
              ),
            );
          }
          final movie = items[index];
          return DyttMovieTile(movie: movie, onTap: () => _open(movie));
        },
      ),
    );
  }
}
