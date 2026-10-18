import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post_card.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_breadcrumb.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_controller.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_repository.dart';
import 'package:flutter/material.dart';

/// State of [TsdmThreadPage].
class TsdmThreadPageState extends State<TsdmThreadPage> {
  TsdmHttpClient? _ownedClient;
  late final TsdmThreadController _controller;

  @override
  void initState() {
    super.initState();
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    final repository =
        widget.repository ?? TsdmThreadRepository(client: client);
    _controller = TsdmThreadController(
      repository: repository,
      tid: widget.tid,
      pid: widget.pid,
      onlyVisibleUid: widget.onlyVisibleUid,
      reverseOrder: widget.reverseOrder,
      exactOrder: widget.exactOrder,
    );
    _controller.addListener(_onControllerChanged);
    _controller.loadPage(1);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.title ?? '帖子 ${widget.tid ?? widget.pid}'),
        bottom: _buildBreadcrumbBar(),
      ),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget? _buildBreadcrumbBar() {
    if (_controller.breadcrumbs.isEmpty) {
      return null;
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(28),
      child: SizedBox(
        height: 28,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.breadcrumbs.length,
          itemBuilder: (context, index) {
            final TsdmThreadBreadcrumb breadcrumb =
                _controller.breadcrumbs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(child: Text(breadcrumb.description)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading() && _controller.postList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.postList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_controller.error}'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _controller.refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_controller.needLogin || !_controller.havePermission) {
      return Center(child: Text(_controller.needLogin ? '需要登录' : '没有权限'));
    }
    return RefreshIndicator(
      onRefresh: () => _controller.refresh(),
      child: ListView.builder(
        itemCount: _controller.postList.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          if (index == _controller.postList.length + 1) {
            return _buildLoadMore();
          }
          final TsdmPost post = _controller.postList[index - 1];
          return TsdmPostCard(post: post);
        },
      ),
    );
  }

  Widget _buildHeader() {
    final viewCount = _controller.viewCount;
    final replyCount = _controller.replyCount;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller.forumName != null)
            Text(_controller.forumName!, style: const TextStyle(fontSize: 12)),
          if (_controller.threadType != null)
            Text('[${_controller.threadType!.name}]'),
          Row(
            children: [
              Expanded(child: Text('${_controller.postList.length} 帖')),
              if (viewCount != null) Text('浏览 $viewCount'),
              if (replyCount != null) Text(' 回复 $replyCount'),
            ],
          ),
          if (_controller.threadClosed) const Text('主题已关闭'),
          if (_controller.threadSoftClosed) const Text('主题暂时关闭'),
          if (_controller.isDraft) const Text('草稿'),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    if (!_controller.canLoadMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: Text('没有更多了')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: _controller.isLoading()
            ? const CircularProgressIndicator()
            : FilledButton(
                onPressed: () =>
                    _controller.loadMore(_controller.currentPage + 1),
                child: Text(
                  '加载第 ${_controller.currentPage + 1} 页 / 共 ${_controller.totalPages} 页',
                ),
              ),
      ),
    );
  }
}
