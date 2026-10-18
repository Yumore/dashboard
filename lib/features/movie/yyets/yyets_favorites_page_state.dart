import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_favorites_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 我的收藏页状态。
///
/// 源工程 `FavoritesPage`：`Api.myFavorites(page)` 分页拉取，每条取 `detail`
/// 子对象当影视卡片。源工程的收藏依赖登录态；宿主没有登录 UI，因此这个页面
/// 只有注入已登录的 [YyetsApi]（`YyetsSession(uid:, token:)`）时才能拿到数据，
/// 否则接口返回未登录错误并走失败态。
class YyetsFavoritesPageState extends State<YyetsFavoritesPage> {
  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  List<YyetsMovie> _items = const <YyetsMovie>[];
  int _page = 1;
  bool _loading = false;
  bool _noMore = false;
  bool _loadedOnce = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  void dispose() {
    _ownedApi?.dispose();
    super.dispose();
  }

  Future<void> _loadMore({bool force = false}) async {
    if (_loading || _noMore || (_error != null && !force)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _api.myFavorites(_page);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadedOnce = true;
        if (page.isEmpty) {
          _noMore = true;
        } else {
          _items = <YyetsMovie>[..._items, ...page];
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

  Future<void> _refresh() async {
    setState(() {
      _items = const <YyetsMovie>[];
      _page = 1;
      _noMore = false;
      _error = null;
    });
    await _loadMore(force: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: RefreshIndicator(onRefresh: _refresh, child: _body()),
    );
  }

  Widget _body() {
    if (!_loadedOnce && _loading) {
      return const YyetsStatusView(loading: true);
    }
    if (_items.isEmpty) {
      return ListView(
        children: <Widget>[
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          YyetsStatusView(
            error: _error,
            emptyText: _error == null && _loadedOnce ? '还没有收藏' : null,
            onRetry: () => _loadMore(force: true),
          ),
        ],
      );
    }
    return ListView.builder(
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
        final movie = _items[index];
        return ListTile(
          title: Text(movie.title),
          subtitle: Text(movie.searchTags.join(' · ')),
          trailing: Text(movie.score),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => YyetsDetailPage(
                movieId: movie.id,
                title: movie.title,
                api: _api,
                launcher: widget.launcher,
              ),
            ),
          ),
        );
      },
    );
  }
}
