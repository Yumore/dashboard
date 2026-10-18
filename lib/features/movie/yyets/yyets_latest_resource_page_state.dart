import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_file_entry.dart';
import 'package:dashboard/features/movie/yyets/yyets_latest_resource_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 最新资源页状态。
///
/// 源工程 `LatestResourcePage`：非搜索态走 `Api.latestResource(page)`，搜索态走
/// `Api.queryRRResource(keyword, page)`（两者都打到 `file.apicvn.com`，响应是
/// 裸数组）。列表项展示文件名/大小/时间，磁力链接点击交给外部下载器。
class YyetsLatestResourcePageState extends State<YyetsLatestResourcePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  final List<YyetsFileEntry> _items = <YyetsFileEntry>[];
  int _page = 1;
  bool _loading = false;
  bool _noMore = false;
  bool _loadedOnce = false;
  String? _error;

  /// 非空时处于搜索结果态。
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _ownedApi?.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore({bool force = false}) async {
    if (_loading || _noMore || (_error != null && !force)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = _keyword.isEmpty
          ? await _api.latestResources(_page)
          : await _api.searchResources(_keyword, _page);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadedOnce = true;
        if (page.isEmpty) {
          _noMore = true;
        } else {
          _items.addAll(page);
          _page += 1;
        }
      });
    } on YyetsException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadedOnce = true;
        _error = error.message;
      });
    }
  }

  void _search() {
    final keyword = _controller.text.trim();
    setState(() {
      _keyword = keyword;
      _items.clear();
      _page = 1;
      _noMore = false;
      _error = null;
      _loadedOnce = false;
    });
    if (keyword.isEmpty) {
      _loadMore(force: true);
      return;
    }
    _loadMore(force: true);
  }

  Future<void> _open(YyetsFileEntry entry) async {
    final address = entry.magnetUrl ?? '';
    final ok = await widget.launcher.open(address);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('该资源没有可打开的磁力链接')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
            hintText: '搜索资源库',
            border: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _search,
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (!_loadedOnce && _loading) {
      return const YyetsStatusView(loading: true);
    }
    if (_items.isEmpty) {
      return YyetsStatusView(
        error: _error,
        emptyText: _error == null && _loadedOnce
            ? (_keyword.isEmpty ? '暂无最新资源' : '没有找到「$_keyword」')
            : null,
        onRetry: () => _loadMore(force: true),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          if (_loading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _error != null
                  ? TextButton(
                      onPressed: () => _loadMore(force: true),
                      child: Text('重试：$_error'),
                    )
                  : Text(_noMore ? '没有更多了' : ''),
            ),
          );
        }
        final entry = _items[index];
        return ListTile(
          leading: Icon(entry.hasMagnet ? Icons.link : Icons.insert_drive_file),
          title: Text(entry.fileName),
          subtitle: Text('${entry.fileSize} · ${entry.createTime}'),
          onTap: entry.hasMagnet ? () => _open(entry) : null,
        );
      },
    );
  }
}
