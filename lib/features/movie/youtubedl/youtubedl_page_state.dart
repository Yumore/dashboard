import 'dart:async';

import 'package:dashboard/features/movie/youtubedl/dio_youtubedl_stream_provider.dart';
import 'package:dashboard/features/movie/youtubedl/dio_youtubedl_stream_sink.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_plan.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_queue.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_status.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_tile.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_page.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_result.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_tile.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_picker_dialog.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_provider.dart';
import 'package:flutter/material.dart';

class YoutubeDlPageState extends State<YoutubeDlPage>
    with SingleTickerProviderStateMixin {
  late final YouTubeStreamProvider _provider;
  late final YoutubeDlDownloadQueue _queue;
  late final bool _ownsQueue;
  late final TabController _tabs;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<YoutubeDlSearchResult> _results = <YoutubeDlSearchResult>[];

  String _continuation = '';
  String _error = '';
  bool _searching = false;
  bool _loadingMore = false;
  String? _openingVideoId;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? DioYouTubeStreamProvider();
    _ownsQueue = widget.queue == null;
    _queue =
        widget.queue ?? YoutubeDlDownloadQueue(sink: DioYouTubeDlStreamSink());
    _tabs = TabController(length: 2, vsync: this);
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _tabs.dispose();
    if (_ownsQueue) _queue.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 200) {
      unawaited(_loadMore());
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;
    setState(() {
      _searching = true;
      _error = '';
      _continuation = '';
    });
    try {
      final page = await _provider.searchVideos(query);
      if (!mounted) return;
      setState(() {
        _results
          ..clear()
          ..addAll(page.items);
        _continuation = page.continuation;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '搜索失败：$error';
        _results.clear();
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _searching || _continuation.isEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final page = await _provider.searchVideos(
        _searchController.text.trim(),
        continuation: _continuation,
      );
      if (!mounted) return;
      setState(() {
        _results.addAll(page.items);
        _continuation = page.continuation;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '加载更多失败：$error');
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _openVideo(YoutubeDlSearchResult result) async {
    if (_openingVideoId != null) return;
    setState(() => _openingVideoId = result.videoId);
    try {
      final player = await _provider.loadPlayer(result.videoId);
      if (!mounted) return;
      final plan = await showDialog<YoutubeDlDownloadPlan>(
        context: context,
        builder: (dialogContext) => YoutubeDlStreamPickerDialog(
          video: player.video,
          manifest: player.manifest,
        ),
      );
      if (!mounted || plan == null) return;
      final task = _queue.enqueue(video: player.video, plan: plan);
      _tabs.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.status == YoutubeDlDownloadStatus.needsMuxer
                ? '需要 FFmpeg 合成，已标记为“需要合成”'
                : '已加入下载队列',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('获取视频流失败：$error')));
    } finally {
      if (mounted) setState(() => _openingVideoId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube 下载'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Tab>[
            Tab(text: '搜索'),
            Tab(text: '下载'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: <Widget>[_buildSearchTab(), _buildDownloadsTab()],
      ),
    );
  }

  Widget _buildSearchTab() {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    hintText: '搜索 YouTube 视频',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _searching ? null : _search,
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        if (_searching) const LinearProgressIndicator(),
        if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              _error,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        Expanded(
          child: _results.isEmpty
              ? Center(child: Text(_searching ? '正在搜索…' : '输入关键词搜索 YouTube 视频'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _results.length + (_loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _results.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final result = _results[index];
                    return YoutubeDlSearchTile(
                      result: result,
                      busy: _openingVideoId == result.videoId,
                      onTap: () => _openVideo(result),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDownloadsTab() {
    return ListenableBuilder(
      listenable: _queue,
      builder: (context, child) {
        final tasks = _queue.tasks;
        if (tasks.isEmpty) {
          return const Center(child: Text('暂无下载任务'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return YoutubeDlDownloadTile(
              task: task,
              now: DateTime.now(),
              onPause: () => _queue.pause(task.id),
              onResume: () => _queue.resume(task.id),
              onCancel: () => _queue.cancel(task.id),
              onRemove: () => unawaited(_queue.remove(task.id)),
            );
          },
        );
      },
    );
  }
}
