import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_routes.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_favorites_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_media_list_item.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicFavoritesPage]; rebuilds on every store
/// notification.
class CinematicFavoritesPageState extends State<CinematicFavoritesPage> {
  CinematicFavoritesStore get _store => widget.store;

  List<CinematicMediaItem> get movieFavorites => _store.movieFavorites;
  List<CinematicMediaItem> get showFavorites => _store.showFavorites;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChanged);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[_list(movieFavorites), _list(showFavorites)],
        ),
      ),
    );
  }

  Widget _list(List<CinematicMediaItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Nothing saved yet'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CinematicMediaListItem(
          item: item,
          onTap: (selected) =>
              Navigator.of(context).push(CinematicRoutes.mediaDetail(selected)),
        );
      },
    );
  }
}
