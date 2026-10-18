import 'package:carousel_slider/carousel_slider.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_home_data.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_home_page.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_movie_card.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_network_image.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_routes.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_section_header.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_status_view.dart';
import 'package:flutter/material.dart';

class FlutterMoviesHomePageState extends State<FlutterMoviesHomePage> {
  FlutterMoviesHomeData _data = const FlutterMoviesHomeData();
  String? _error;
  bool _loading = false;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 只在 initState / 用户回调里发请求，build 里永远不发。
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final failures = <String>[];
    var sliders = <FlutterMoviesListItem>[];
    var updates = <FlutterMoviesListItem>[];
    var parents = <FlutterMoviesCategory>[];

    try {
      sliders = (await widget.api.homeSliders()).items;
    } catch (exception) {
      failures.add(_messageOf(exception));
    }
    try {
      updates = (await widget.api.updates(pagesize: 6)).items;
    } catch (exception) {
      failures.add(_messageOf(exception));
    }
    try {
      parents = await widget.api.parentCategories();
    } catch (exception) {
      failures.add(_messageOf(exception));
    }

    final grids = <int, List<FlutterMoviesListItem>>{};
    for (final parent in parents) {
      try {
        grids[parent.typeId] = (await widget.api.homeGridByParent(
          parent.typeId,
        )).items;
      } catch (_) {
        // 单个分组失败不影响其它分组。
        grids[parent.typeId] = const <FlutterMoviesListItem>[];
      }
    }

    if (!mounted) return;
    final data = FlutterMoviesHomeData(
      sliders: sliders,
      parents: parents,
      updates: updates,
      grids: grids,
    );
    setState(() {
      _data = data;
      _loading = false;
      _loadedOnce = true;
      _error = data.isEmpty && failures.isNotEmpty ? failures.first : null;
    });
  }

  static String _messageOf(Object exception) =>
      exception is FlutterMoviesException ? exception.message : '$exception';

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce && _loading) {
      return const FlutterMoviesStatusView.loading();
    }
    final error = _error;
    if (error != null) {
      return FlutterMoviesStatusView.error(error, onRetry: _load);
    }
    if (_data.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 96),
            FlutterMoviesStatusView.empty('暂无推荐内容'),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (_data.sliders.isNotEmpty) _sliders(),
          if (_data.updates.isNotEmpty) ...[
            const FlutterMoviesSectionHeader(title: '最近更新'),
            _horizontal(_data.updates),
          ],
          for (final parent in _data.parents)
            if (_data.gridOf(parent.typeId).isNotEmpty) ...<Widget>[
              FlutterMoviesSectionHeader(title: parent.typeName),
              _horizontal(_data.gridOf(parent.typeId)),
            ],
        ],
      ),
    );
  }

  Widget _sliders() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: CarouselSlider(
      options: CarouselOptions(
        height: 180,
        viewportFraction: 0.9,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: _data.sliders
          .map(
            (item) => GestureDetector(
              onTap: () => _openDetail(item),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FlutterMoviesNetworkImage(
                    imageUrl: widget.api.imageUrl(item.primaryImage),
                    radius: 12,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    ),
  );

  Widget _horizontal(List<FlutterMoviesListItem> items) => SizedBox(
    height: 200,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return SizedBox(
          width: 112,
          child: FlutterMoviesMovieCard.of(
            item,
            imageUrl: widget.api.imageUrl(item.listImage),
            onTap: () => _openDetail(item),
          ),
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
