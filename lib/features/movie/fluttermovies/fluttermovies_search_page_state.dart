import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_grid_view.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_list.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_routes.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_search_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_view.dart';
import 'package:flutter/material.dart';

class FlutterMoviesSearchPageState extends State<FlutterMoviesSearchPage> {
  final TextEditingController _input = TextEditingController();
  FlutterMoviesPagedList? _list;
  String _keyword = '';
  String? _error;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _input.text.trim();
    if (keyword.isEmpty) return;
    final list = FlutterMoviesPagedList(
      (page) => widget.api.search(keyword, pg: page),
    );
    setState(() {
      _keyword = keyword;
      _list = list;
      _error = null;
    });
    await list.refresh();
    if (!mounted) return;
    if (list.items.isEmpty && list.error != null) {
      setState(() => _error = list.error);
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    final list = _list;
    if (list == null) return;
    await list.refresh();
    if (mounted) setState(() {});
  }

  Future<void> _loadMore() async {
    final list = _list;
    if (list == null || list.loading || !list.hasMore) return;
    await list.loadMore();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            controller: _input,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: '搜索影片、电视剧、动漫',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: '搜索',
                icon: const Icon(Icons.arrow_forward),
                onPressed: _search,
              ),
            ),
          ),
        ),
        Expanded(child: _body(list)),
      ],
    );
  }

  Widget _body(FlutterMoviesPagedList? list) {
    if (list == null) {
      return const FlutterMoviesStatusView.empty('输入关键词后开始搜索');
    }
    final error = _error;
    if (list.items.isEmpty && error != null) {
      return FlutterMoviesStatusView.error(error, onRetry: _refresh);
    }
    if (list.items.isEmpty && !list.loading) {
      return FlutterMoviesStatusView.empty('没有找到「$_keyword」相关内容');
    }
    return FlutterMoviesPagedGridView(
      list: list,
      imageUrl: (item) => widget.api.imageUrl(item.listImage),
      onTap: _openDetail,
      onRefresh: _refresh,
      onLoadMore: _loadMore,
      emptyMessage: '没有找到「$_keyword」相关内容',
    );
  }

  void _openDetail(FlutterMoviesListItem item) =>
      FlutterMoviesRoutes.openDetail(
        context,
        api: widget.api,
        vodId: item.vodId,
      );
}
