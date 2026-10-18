import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_controller.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_latest_thread_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page.dart';
import 'package:flutter/material.dart';

/// State of [TsdmLatestThreadPage].
class TsdmLatestThreadPageState extends State<TsdmLatestThreadPage> {
  TsdmHttpClient? _ownedClient;
  late final TsdmLatestThreadController _controller;

  @override
  void initState() {
    super.initState();
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    _controller = TsdmLatestThreadController(
      repository:
          widget.repository ?? TsdmLatestThreadRepository(client: client),
    )..addListener(_onControllerChanged);
    _controller.refresh(widget.url);
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
      appBar: AppBar(title: Text(widget.title ?? '最新主题')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.status == TsdmLatestThreadStatus.loading &&
        _controller.threadList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null && _controller.threadList.isEmpty) {
      return Center(child: Text('加载失败：${_controller.error}'));
    }
    if (_controller.threadList.isEmpty) {
      return const Center(child: Text('没有主题'));
    }
    return RefreshIndicator(
      onRefresh: () => _controller.refresh(widget.url),
      child: ListView.builder(
        itemCount: _controller.threadList.length + 1,
        itemBuilder: (context, index) {
          if (index == _controller.threadList.length) {
            return _buildLoadMore();
          }
          final TsdmLatestThread thread = _controller.threadList[index];
          return ListTile(
            title: Text(thread.title),
            subtitle: Text(
              '${thread.forumName} · 回复 ${thread.replyCount} · 查看 ${thread.viewCount}',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TsdmThreadPage(tid: thread.threadID),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMore() {
    if (_controller.nextPageUrl == null) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: Text('没有更多了')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: _controller.status == TsdmLatestThreadStatus.loading
            ? const CircularProgressIndicator()
            : FilledButton(
                onPressed: _controller.loadMore,
                child: const Text('加载更多'),
              ),
      ),
    );
  }
}
