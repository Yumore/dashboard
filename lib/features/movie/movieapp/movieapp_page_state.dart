import 'package:carousel_slider/carousel_slider.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_api.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_details_page.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_list_result.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_movie.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_network_image.dart';
import 'package:dashboard/features/movie/movieapp/movieapp_page.dart';
import 'package:flutter/material.dart';

class MovieAppPageState extends State<MovieAppPage> {
  final MovieAppApi _api = MovieAppApi();
  final TextEditingController _searchInput = TextEditingController();

  late Future<MovieAppListResult> _nowPlaying;
  late Future<MovieAppListResult> _upcoming;
  late Future<MovieAppListResult> _popular;
  late Future<MovieAppListResult> _topRated;
  late Future<MovieAppListResult> _discover;
  late Future<MovieAppListResult> _onTheAir;
  late Future<MovieAppListResult> _airingToday;
  late Future<MovieAppListResult> _tvPopular;

  final List<MovieAppMovie> _searchResults = [];
  String? _searchError;
  bool _searching = false;
  bool _searchSubmitted = false;
  int _searchPage = 0;
  int _searchTotalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  /// Every request starts here or in a user callback — never in `build`.
  void _loadHome() {
    _nowPlaying = _api.nowPlaying();
    _upcoming = _api.upcoming();
    _popular = _api.popular();
    _topRated = _api.topRated();
    _discover = _api.discover();
    _onTheAir = _api.tvOnTheAir();
    _airingToday = _api.tvAiringToday();
    _tvPopular = _api.tvPopular();
  }

  Future<void> _refreshHome() async {
    setState(_loadHome);
    for (final future in [
      _nowPlaying,
      _upcoming,
      _popular,
      _topRated,
      _discover,
      _onTheAir,
      _airingToday,
      _tvPopular,
    ]) {
      try {
        await future;
      } catch (_) {
        // Each section renders its own error + retry state.
      }
    }
  }

  Future<void> _openDetails(MovieAppMovie movie) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieAppDetailsPage(movie: movie, api: _api),
      ),
    );
  }

  Future<void> _search({bool loadMore = false}) async {
    final query = _searchInput.text.trim();
    if (query.isEmpty) return;
    if (loadMore && (_searching || _searchPage >= _searchTotalPages)) return;
    final nextPage = loadMore ? _searchPage + 1 : 1;
    setState(() {
      _searching = true;
      _searchSubmitted = true;
      if (!loadMore) {
        _searchResults.clear();
        _searchError = null;
        _searchPage = 0;
        _searchTotalPages = 0;
      }
    });
    try {
      final result = await _api.search(query, page: nextPage);
      if (!mounted) return;
      setState(() {
        _searchResults.addAll(result.results);
        _searchPage = result.page;
        _searchTotalPages = result.totalPages;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _searchError = '$error');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  void dispose() {
    _searchInput.dispose();
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 4,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('MovieApp · TMDb'),
        bottom: const TabBar(
          tabs: [
            Tab(text: '电影'),
            Tab(text: '剧集'),
            Tab(text: '发现'),
            Tab(text: '搜索'),
          ],
        ),
      ),
      body: TabBarView(
        children: [_moviesTab(), _tvTab(), _discoverTab(), _searchTab()],
      ),
    ),
  );

  Widget _moviesTab() => RefreshIndicator(
    onRefresh: _refreshHome,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _banner(_nowPlaying),
        _section('即将上映', _upcoming),
        _section('热门电影', _popular),
        _section('高分电影', _topRated),
        const SizedBox(height: 16),
      ],
    ),
  );

  Widget _tvTab() => RefreshIndicator(
    onRefresh: _refreshHome,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _banner(_onTheAir),
        _section('今日播出', _airingToday),
        _section('热门剧集', _tvPopular),
        const SizedBox(height: 16),
      ],
    ),
  );

  /// Port of the source's full-screen Discover flow, now driven by
  /// `discover/movie`.
  Widget _discoverTab() => RefreshIndicator(
    onRefresh: _refreshHome,
    child: FutureBuilder<MovieAppListResult>(
      future: _discover,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _errorBox(snapshot.error);
        final result = snapshot.data;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = result.results.take(20).toList();
        if (items.isEmpty) return const Center(child: Text('暂无内容'));
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) => _discoverCard(items[index]),
        );
      },
    ),
  );

  Widget _discoverCard(MovieAppMovie movie) => GestureDetector(
    onTap: () => _openDetails(movie),
    child: Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: MovieAppNetworkImage(movie.backdropUrl),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    movie.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '★${movie.voteAverage.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _banner(Future<MovieAppListResult> future) =>
      FutureBuilder<MovieAppListResult>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _errorBox(snapshot.error);
          final result = snapshot.data;
          if (result == null) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final items = result.results.take(10).toList();
          if (items.isEmpty) {
            return const SizedBox(
              height: 180,
              child: Center(child: Text('暂无内容')),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                viewportFraction: 0.9,
                enlargeCenterPage: true,
              ),
              items: [for (final movie in items) _bannerItem(movie)],
            ),
          );
        },
      );

  Widget _bannerItem(MovieAppMovie movie) => GestureDetector(
    onTap: () => _openDetails(movie),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MovieAppNetworkImage(movie.backdropUrl),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: Text(
                movie.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _section(
    String title,
    Future<MovieAppListResult> future, {
    int limit = 5,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 200,
        child: FutureBuilder<MovieAppListResult>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) return _errorBox(snapshot.error);
            final result = snapshot.data;
            if (result == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = result.results.take(limit).toList();
            if (items.isEmpty) return const Center(child: Text('暂无内容'));
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) => _posterCard(items[index]),
            );
          },
        ),
      ),
    ],
  );

  Widget _posterCard(MovieAppMovie movie) => GestureDetector(
    onTap: () => _openDetails(movie),
    child: Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 120,
              height: 150,
              child: MovieAppNetworkImage(movie.posterUrl),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            '${movie.year} · ★${movie.voteAverage.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    ),
  );

  Widget _errorBox(Object? error) => SizedBox(
    height: 140,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('加载失败：${error ?? '未知错误'}', textAlign: TextAlign.center),
          ),
          TextButton(
            onPressed: () => setState(_loadHome),
            child: const Text('重试'),
          ),
        ],
      ),
    ),
  );

  Widget _searchTab() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _searchInput,
          decoration: InputDecoration(
            labelText: '搜索 TMDb 影片',
            suffixIcon: IconButton(
              onPressed: () => _search(),
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (_) => _search(),
        ),
      ),
      if (_searchError != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(child: Text('搜索失败：$_searchError')),
              TextButton(
                onPressed: () => _search(loadMore: _searchPage > 0),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      Expanded(child: _searchBody()),
    ],
  );

  Widget _searchBody() {
    if (!_searchSubmitted) {
      return const Center(child: Text('输入关键词搜索 TMDb 影片'));
    }
    if (_searching && _searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return Center(child: Text(_searchError == null ? '未找到相关影片' : '搜索失败，请重试'));
    }
    return ListView.builder(
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) => index == _searchResults.length
          ? _searchFooter()
          : _searchTile(_searchResults[index]),
    );
  }

  Widget _searchFooter() {
    if (_searching) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_searchPage >= _searchTotalPages) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('没有更多结果了')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TextButton(
          onPressed: () => _search(loadMore: true),
          child: const Text('加载更多'),
        ),
      ),
    );
  }

  Widget _searchTile(MovieAppMovie movie) => ListTile(
    leading: SizedBox(
      width: 40,
      height: 60,
      child: MovieAppNetworkImage(movie.posterUrl),
    ),
    title: Text(movie.displayTitle),
    subtitle: Text('${movie.year} · ★${movie.voteAverage.toStringAsFixed(1)}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _openDetails(movie),
  );
}
