import 'package:dashboard/features/movie/yyets/yyets_api.dart';
import 'package:dashboard/features/movie/yyets/yyets_detail_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_exception.dart';
import 'package:dashboard/features/movie/yyets/yyets_home_page.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie_card.dart';
import 'package:dashboard/features/movie/yyets/yyets_rank_result.dart';
import 'package:dashboard/features/movie/yyets/yyets_status_view.dart';
import 'package:flutter/material.dart';

/// 榜单首页的状态。
///
/// 源工程 `RankPage`：进页面 `Api.loadRank()` 一次拿回 6 个榜单，再用
/// `TabBar` + `GridView` 展示。这里保留同样的“一次请求 + 本地切 tab”行为，
/// 不做每个 tab 单独请求（源工程就是这样，切 tab 不重新请求）。
class YyetsHomePageState extends State<YyetsHomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: YyetsRankResult.tabs.length,
    vsync: this,
  );

  YyetsApi? _ownedApi;
  YyetsApi get _api => widget.api ?? (_ownedApi ??= YyetsApi());

  YyetsRankResult? _rank;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ownedApi?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rank = await _api.loadRank();
      if (!mounted) return;
      setState(() {
        _rank = rank;
        _loading = false;
      });
    } on YyetsException catch (error) {
      if (!mounted) return;
      setState(() {
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
    final rank = _rank;
    if (rank == null || _loading || _error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('人人影视')),
        body: YyetsStatusView(loading: _loading, error: _error, onRetry: _load),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('人人影视'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: <Widget>[
            for (final tab in YyetsRankResult.tabs)
              Tab(icon: Icon(tab.icon), text: tab.label),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          for (final tab in YyetsRankResult.tabs) _tabBody(rank.listFor(tab)),
        ],
      ),
    );
  }

  Widget _tabBody(List<YyetsMovie> movies) {
    if (movies.isEmpty) {
      return const YyetsStatusView(emptyText: '榜单暂无数据');
    }
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        childAspectRatio: 0.62,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return YyetsMovieCard(movie: movie, onTap: () => _openDetail(movie));
      },
    );
  }
}
