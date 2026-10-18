import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_controller.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_normal_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_card.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page.dart';
import 'package:flutter/material.dart';

/// State of [TsdmForumPage].
class TsdmForumPageState extends State<TsdmForumPage>
    with SingleTickerProviderStateMixin {
  late final TsdmForumController _controller;
  late final TabController _tabController;
  TsdmHttpClient? _ownedClient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    final repository = widget.repository ?? TsdmForumRepository(client: client);
    _controller = TsdmForumController(repository: repository, fid: widget.fid)
      ..filterState = widget.filterState ?? const TsdmFilterState();
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
    _tabController.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.title ?? widget.title ?? '论坛 ${widget.fid}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '置顶 ${_controller.stickThreadList.length}'),
            Tab(text: '主题 ${_controller.normalThreadList.length}'),
            Tab(text: '子版块 ${_controller.subredditList.length}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildThreadList(
            _controller.stickThreadList.map((e) => _buildCard(e)).toList(),
          ),
          _buildNormalThreads(),
          _buildSubForums(),
        ],
      ),
    );
  }

  Widget _buildCard(TsdmNormalThread thread) {
    return TsdmThreadCard(
      thread: thread,
      onTap: () => _openThread(thread.threadID),
    );
  }

  Widget _buildNormalThreads() {
    if (_controller.isLoading() && _controller.normalThreadList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.needLogin || !_controller.havePermission) {
      return _buildPermissionMessage();
    }
    if (_controller.normalThreadList.isEmpty) {
      return const Center(child: Text('没有主题'));
    }
    return RefreshIndicator(
      onRefresh: () => _controller.refresh(),
      child: ListView.builder(
        itemCount: _controller.normalThreadList.length + 1,
        itemBuilder: (context, index) {
          if (index == _controller.normalThreadList.length) {
            return _buildLoadMore();
          }
          final thread = _controller.normalThreadList[index];
          return TsdmThreadCard(
            thread: thread,
            onTap: () => _openThread(thread.threadID),
          );
        },
      ),
    );
  }

  Widget _buildThreadList(List<Widget> children) {
    if (children.isEmpty) {
      return const Center(child: Text('没有置顶主题'));
    }
    return ListView(children: children);
  }

  Widget _buildSubForums() {
    if (_controller.subredditList.isEmpty) {
      return const Center(child: Text('没有子版块'));
    }
    return ListView.builder(
      itemCount: _controller.subredditList.length,
      itemBuilder: (context, index) {
        final forum = _controller.subredditList[index];
        return ListTile(
          title: Text(forum.name),
          subtitle: forum.latestThreadTitle == null
              ? null
              : Text(forum.latestThreadTitle!),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openForum(forum),
        );
      },
    );
  }

  Widget _buildPermissionMessage() {
    final message = _controller.permissionDeniedMessage?.text.trim();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_controller.needLogin ? '需要登录' : '没有权限'),
          if (message != null && message.isNotEmpty) Text(message),
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
                child: Text('加载第 ${_controller.currentPage + 1} 页'),
              ),
      ),
    );
  }

  void _openThread(String tid) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => TsdmThreadPage(tid: tid)));
  }

  void _openForum(TsdmForum forum) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            TsdmForumPage(fid: '${forum.forumID}', title: forum.name),
      ),
    );
  }
}
