import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_search_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_search_result_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_status_view.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page.dart';
import 'package:flutter/material.dart';

class EyepetizerSearchPageState extends State<EyepetizerSearchPage> {
  late final EyepetizerApi _api;
  late final bool _ownsApi;

  final TextEditingController _controller = TextEditingController();
  List<String> _keywords = const <String>[];
  List<EyepetizerItem> _results = const <EyepetizerItem>[];
  int _total = 0;
  String? _nextPageUrl;
  bool _loadingKeywords = false;
  bool _loading = false;
  bool _loadingMore = false;

  /// True once a query has been submitted; before that the chips are shown.
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? EyepetizerApi();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isEmpty) {
      unawaited(_loadKeywords());
    } else {
      _controller.text = initial;
      unawaited(_submit(initial));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  Future<void> _loadKeywords() async {
    setState(() => _loadingKeywords = true);
    try {
      final keywords = await _api.hotKeywords();
      if (!mounted) return;
      setState(() {
        _keywords = keywords;
        _loadingKeywords = false;
      });
    } on Object {
      if (!mounted) return;
      // The source silently swallowed a keyword failure and left the chips
      // empty (`video_search_model.dart` used an unguarded `getData`).
      setState(() => _loadingKeywords = false);
    }
  }

  Future<void> _submit(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _loading = true;
      _error = null;
      _results = const <EyepetizerItem>[];
      _nextPageUrl = null;
      _total = 0;
    });
    try {
      final issue = await _api.search(query);
      if (!mounted) return;
      setState(() {
        _results = _playable(issue.itemList);
        _total = issue.total;
        _nextPageUrl = issue.nextPageUrl;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is EyepetizerException ? error.message : '搜索失败，请重试';
      });
    }
  }

  Future<void> _loadMore() async {
    final next = _nextPageUrl;
    if (next == null || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final issue = await _api.searchPage(next);
      if (!mounted) return;
      setState(() {
        _results = <EyepetizerItem>[..._results, ..._playable(issue.itemList)];
        _nextPageUrl = issue.nextPageUrl;
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            error is EyepetizerException ? error.message : '加载失败，请重试',
          ),
        ),
      );
    }
  }

  /// The source removed every hit whose `data.cover` was null
  /// (`video_search_model.dart`, `itemList.removeWhere`).
  static List<EyepetizerItem> _playable(List<EyepetizerItem> source) => source
      .where((item) => item.data != null && item.data!.cover != null)
      .toList(growable: false);

  void _openDetail(EyepetizerItem item) {
    final data = item.data;
    if (data == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EyepetizerVideoDetailPage(data: data, api: _api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: '搜索视频',
            border: InputBorder.none,
          ),
          onSubmitted: (value) => unawaited(_submit(value)),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search),
            onPressed: () => unawaited(_submit(_controller.text)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_searching) return _keywordBody();
    if (_loading) return const EyepetizerStatusView.loading();
    final error = _error;
    if (error != null) {
      return EyepetizerStatusView.error(
        error,
        onRetry: () => unawaited(_submit(_controller.text)),
      );
    }
    if (_results.isEmpty) {
      return const EyepetizerStatusView.empty('没有找到相关视频');
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 600) unawaited(_loadMore());
        return false;
      },
      child: ListView.builder(
        itemCount: _results.length + 1,
        itemBuilder: (context, index) {
          if (index == _results.length) return _footer(context);
          final item = _results[index];
          return EyepetizerSearchResultItem(
            item: item,
            onTap: () => _openDetail(item),
          );
        },
      ),
    );
  }

  Widget _keywordBody() {
    if (_loadingKeywords) return const EyepetizerStatusView.loading();
    if (_keywords.isEmpty) {
      return const EyepetizerStatusView.empty('暂无热门搜索');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('热门搜索', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final keyword in _keywords)
                ActionChip(
                  label: Text(keyword),
                  onPressed: () {
                    _controller.text = keyword;
                    unawaited(_submit(keyword));
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          _nextPageUrl == null ? '共 $_total 个结果' : '上拉加载更多',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
