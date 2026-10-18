import 'package:dashboard/features/movie/flutterdouban/flutterdouban_api.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_search_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_factory.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_status_view.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_row.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_tile.dart';
import 'package:flutter/material.dart';

/// State for [FlutterDouBanSearchPage].
///
/// The query is only issued from [_submit] / [_loadMore]; `build` never calls
/// the source.
class FlutterDouBanSearchPageState extends State<FlutterDouBanSearchPage> {
  late final FlutterDouBanDataSource _source = createFlutterDouBanSource(
    useNetData: widget.useNetData,
    dio: widget.dio,
    assetLoader: widget.assetLoader,
  );

  final TextEditingController _queryInput = TextEditingController();
  final List<FlutterDouBanSubject> _results = <FlutterDouBanSubject>[];

  bool _searching = false;
  bool _searched = false;
  Object? _error;
  String _submitted = '';
  String? _origin;
  int _nextStart = 0;
  int _total = 0;
  bool _hasMore = false;

  @override
  void dispose() {
    _queryInput.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final query = _queryInput.text.trim();
    if (query.isEmpty || _searching) return;
    setState(() {
      _submitted = query;
      _searched = true;
      _error = null;
      _origin = null;
      _results.clear();
      _nextStart = 0;
      _total = 0;
      _hasMore = false;
    });
    await _run(query, start: 0);
  }

  Future<void> _loadMore() async {
    if (_searching || !_hasMore || _submitted.isEmpty) return;
    await _run(_submitted, start: _nextStart);
  }

  Future<void> _run(String query, {required int start}) async {
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final data = await _source.search(
        query,
        start: start,
        count: FlutterDouBanApi.defaultCount,
      );
      if (!mounted) return;
      setState(() {
        _searching = false;
        _origin = data.label;
        _results.addAll(data.value.subjects);
        _total = data.value.total;
        _nextStart = start + data.value.subjects.length;
        _hasMore = data.value.hasMore;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = error;
      });
    }
  }

  void _openSubject(FlutterDouBanSubject subject) {
    if (subject.id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterDouBanSubjectPage(
          subjectId: subject.id,
          title: subject.displayTitle,
          useNetData: widget.useNetData,
          dio: widget.dio,
          assetLoader: widget.assetLoader,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _queryInput,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: '搜索豆瓣电影',
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: _searching ? null : _submit,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_searching && _results.isEmpty) {
      return const FlutterDouBanStatusView.loading();
    }
    if (_error != null && _results.isEmpty) {
      return FlutterDouBanStatusView.error(
        '搜索失败：$_error',
        onRetry: () => _run(_submitted, start: 0),
      );
    }
    if (!_searched) {
      return const FlutterDouBanStatusView.empty('输入关键词搜索豆瓣电影');
    }
    if (_results.isEmpty) {
      return const FlutterDouBanStatusView.empty('未找到相关影片');
    }
    return Column(
      children: [
        if (_origin != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '数据来源：$_origin · 共 $_total 条',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length + 1,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == _results.length) return _footer();
              final subject = _results[index];
              return FlutterDouBanSubjectTile(
                row: FlutterDouBanSubjectRow(subject: subject),
                onTap: () => _openSubject(subject),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _footer() {
    if (_searching) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: TextButton(onPressed: _loadMore, child: const Text('加载失败，重试')),
        ),
      );
    }
    if (_hasMore) {
      return Center(
        child: TextButton(onPressed: _loadMore, child: const Text('加载更多')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text('没有更多结果了', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}
