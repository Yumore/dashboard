import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_news_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 资讯页状态。
///
/// 源工程 `NewsPage`：`Api.news(page)` 分页拉取，条目可能是微博或文章，
/// 点击用 `webUrl`（微博取 `url`，文章取 `m1.rryslink.com/article/<id>`）
/// 交给外部浏览器/WebView。
class YyetsNewsPageState extends State<YyetsNewsPage> {
  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  final List<YyetsNewsItem> _items = <YyetsNewsItem>[];
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
      final page = await _api.news(_page);
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

  Future<void> _open(YyetsNewsItem item) async {
    final ok = await widget.launcher.open(item.webUrl);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('打开资讯失败')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('人人影视资讯')),
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
        emptyText: _error == null && _loadedOnce ? '暂无资讯' : null,
        onRetry: () => _loadMore(force: true),
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
        return _newsTile(_items[index]);
      },
    );
  }

  Widget _newsTile(YyetsNewsItem item) {
    final image = item.imageUrl;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: image == null
            ? const Icon(Icons.article_outlined)
            : SizedBox(
                width: 56,
                height: 56,
                child: CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
              ),
        title: Text(item.title),
        subtitle: Text(
          <String>[
            if (item.author.isNotEmpty) item.author,
            if (item.isVideo) '视频',
            '赞 ${item.likeCount}',
          ].join(' · '),
        ),
        onTap: () => _open(item),
      ),
    );
  }
}
