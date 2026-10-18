import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_controller.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_searched_thread.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_page.dart';
import 'package:flutter/material.dart';

/// State of [TsdmSearchPage].
class TsdmSearchPageState extends State<TsdmSearchPage> {
  late final TextEditingController _keywordController;
  late final TextEditingController _fidController;
  late final TextEditingController _uidController;
  TsdmHttpClient? _ownedClient;
  late final TsdmSearchController _controller;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController(
      text: widget.initialKeyword ?? '',
    );
    _fidController = TextEditingController(text: widget.fid);
    _uidController = TextEditingController(text: widget.uid);
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    _controller = TsdmSearchController(
      repository: widget.repository ?? TsdmSearchRepository(client: client),
    );
    _controller.addListener(_onControllerChanged);
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _controller.search(
        searchKeyword: widget.initialKeyword!,
        searchFid: widget.fid,
        searchUid: widget.uid,
      );
    }
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
    _keywordController.dispose();
    _fidController.dispose();
    _uidController.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜索')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _keywordController,
                  decoration: const InputDecoration(labelText: '关键词'),
                  onSubmitted: (_) => _search(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fidController,
                        decoration: const InputDecoration(
                          labelText: '版块 fid（0 为全部）',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _uidController,
                        decoration: const InputDecoration(
                          labelText: '作者 uid（0 为全部）',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton(onPressed: _search, child: const Text('搜索')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildResult()),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_controller.status == TsdmSearchStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.error != null) {
      return Center(child: Text('搜索失败：${_controller.error}'));
    }
    final result = _controller.searchResult;
    if (result == null || result.data == null || result.data!.isEmpty) {
      return const Center(child: Text('没有搜索结果'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '共 ${result.count ?? 0} 条，第 ${result.currentPage} / ${result.totalPages} 页',
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: result.data!.length,
            itemBuilder: (context, index) {
              final TsdmSearchedThread thread = result.data![index];
              return ListTile(
                title: Text(thread.title),
                subtitle: Text(
                  '${thread.forumName} · ${thread.author.name} · ${thread.publishTime}',
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TsdmThreadPage(tid: '${thread.tid}'),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _controller.hasPreviousPage
                    ? _controller.gotoPreviousPage
                    : null,
                child: const Text('上一页'),
              ),
              Text('${_controller.pageNumber}'),
              TextButton(
                onPressed: _controller.hasNextPage
                    ? _controller.gotoNextPage
                    : null,
                child: const Text('下一页'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _search() {
    _controller.search(
      searchKeyword: _keywordController.text,
      searchFid: _fidController.text,
      searchUid: _uidController.text,
    );
  }
}
