import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_grid_view.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_paged_list.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_ranking_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_routes.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_view.dart';
import 'package:flutter/material.dart';

class FlutterMoviesRankingPageState extends State<FlutterMoviesRankingPage> {
  List<FlutterMoviesCategory> _parents = const <FlutterMoviesCategory>[];
  int _parentIndex = 0;
  FlutterMoviesPagedList? _list;
  String? _error;
  bool _loading = false;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _load(0);
  }

  Future<void> _load(int parentIndex) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final parents = _parents.isEmpty
          ? await widget.api.parentCategories()
          : _parents;
      if (parents.isEmpty) {
        if (!mounted) return;
        setState(() {
          _parents = const <FlutterMoviesCategory>[];
          _list = null;
          _loading = false;
          _loadedOnce = true;
        });
        return;
      }
      final index = parentIndex.clamp(0, parents.length - 1);
      final list = FlutterMoviesPagedList(
        (page) => widget.api.ranking(pt: parents[index].typeId, pg: page),
      );
      if (!mounted) return;
      setState(() {
        _parents = parents;
        _parentIndex = index;
        _list = list;
        _loading = false;
        _loadedOnce = true;
      });
      await _refresh();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        _error = _messageOf(exception);
        _loading = false;
        _loadedOnce = true;
      });
    }
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

  static String _messageOf(Object exception) =>
      exception is FlutterMoviesException ? exception.message : '$exception';

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) return const FlutterMoviesStatusView.loading();
    final error = _error;
    if (error != null && _list == null) {
      return FlutterMoviesStatusView.error(error, onRetry: () => _load(0));
    }
    if (_parents.isEmpty) {
      return const FlutterMoviesStatusView.empty('暂无排行数据');
    }
    return Column(
      children: [
        _parentTabs(),
        Expanded(
          child: _loading && _list == null
              ? const FlutterMoviesStatusView.loading()
              : _list == null
              ? const FlutterMoviesStatusView.empty('暂无排行数据')
              : FlutterMoviesPagedGridView(
                  list: _list!,
                  imageUrl: (item) => widget.api.imageUrl(item.listImage),
                  onTap: _openDetail,
                  onRefresh: _refresh,
                  onLoadMore: _loadMore,
                  emptyMessage: '暂无排行数据',
                ),
        ),
      ],
    );
  }

  Widget _parentTabs() => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      itemCount: _parents.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final parent = _parents[index];
        return ChoiceChip(
          label: Text(parent.typeName),
          selected: index == _parentIndex,
          onSelected: (_) => _load(index),
        );
      },
    ),
  );

  void _openDetail(FlutterMoviesListItem item) =>
      FlutterMoviesRoutes.openDetail(
        context,
        api: widget.api,
        vodId: item.vodId,
      );
}
