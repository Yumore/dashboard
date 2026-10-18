import 'dart:async';

import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie_card.dart';
import 'package:dashboard/features/movie/yyets/yyets_paging.dart';
import 'package:dashboard/features/movie/yyets/yyets_search_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 搜索页状态。
///
/// 源工程 `SearchPage`：搜索框提交后 `Api.search(k, page)`，每页 10 条，
/// 滚动到底继续取下一页，返回空列表表示没有更多。这里用 [YyetsPaging] 把
/// 这套分页状态显式化。
class YyetsSearchPageState extends State<YyetsSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final YyetsPaging<YyetsMovie> _paging = YyetsPaging<YyetsMovie>();

  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  /// 当前生效的关键字（提交时快照，避免翻页时输入框内容变化）。
  String _query = '';
  bool _searched = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.initialQuery.trim().isNotEmpty) {
      _controller.text = widget.initialQuery;
      _submit();
    }
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

  void _submit() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = '搜索关键字不能为空';
        _searched = false;
        _paging.reset();
      });
      return;
    }
    setState(() {
      _query = query;
      _searched = true;
      _error = null;
      _paging.reset();
    });
    unawaited(_loadMore());
  }

  /// 取下一页。
  ///
  /// [force] 为 true 时忽略上一次失败留下的 `hasError`，用于失败态的重试按钮。
  Future<void> _loadMore({bool force = false}) async {
    if (_loading) return;
    if (_searched && !_paging.canLoadMore && !force) return;
    if (_query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _api.search(_query, _paging.page);
      if (!mounted) return;
      setState(() {
        _paging.append(items);
        _loading = false;
      });
    } on YyetsException catch (error) {
      if (!mounted) return;
      setState(() {
        _paging.fail();
        _error = error.message;
        _loading = false;
      });
    }
  }

  void _openDetail(YyetsMovie movie) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => YyetsDetailPage(
          movieId: movie.id,
          title: movie.title,
          api: _api,
          launcher: widget.launcher,
        ),
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
          onSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            hintText: '搜索影视，如：三体',
            border: InputBorder.none,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (!_searched) {
      return YyetsStatusView(
        error: _error,
        emptyText: _error == null ? '输入关键字搜索影视' : null,
      );
    }
    if (_paging.isEmpty) {
      if (_loading) return const YyetsStatusView(loading: true);
      if (_error != null) {
        return YyetsStatusView(
          error: _error,
          onRetry: () => _loadMore(force: true),
        );
      }
      if (_paging.noMore) {
        return YyetsStatusView(emptyText: '没有找到「$_query」相关的影视');
      }
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: _paging.items.length + 1,
      itemBuilder: (context, index) {
        if (index == _paging.items.length) return _footer();
        final movie = _paging.items[index];
        return ListTile(
          leading: SizedBox(
            width: 56,
            height: 78,
            child: YyetsMovieCard(movie: movie, showTitle: false),
          ),
          title: Text(movie.title),
          subtitle: Text(
            <String>[
              if (movie.typeName.trim().isNotEmpty) movie.typeName,
              ...movie.searchTags,
            ].join(' · '),
          ),
          trailing: movie.score.trim().isEmpty
              ? null
              : Text(
                  movie.score,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
          onTap: () => _openDetail(movie),
        );
      },
    );
  }

  Widget _footer() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton(
            onPressed: () => _loadMore(force: true),
            child: Text('重试：$_error'),
          ),
        ),
      );
    }
    if (_paging.noMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('没有更多了')),
      );
    }
    return const SizedBox(height: 16);
  }
}
