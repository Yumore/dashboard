import 'package:dashboard/features/movie/fluttercinematic/cinematic_api.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_constants.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_favorites_store.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_paging_controller.dart';
import 'package:dashboard/features/movie/fluttercinematic/cinematic_routes.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_favorites_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/pages/cinematic_home_page.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_favorite_button.dart';
import 'package:dashboard/features/movie/fluttercinematic/widgets/cinematic_media_list.dart';
import 'package:flutter/material.dart';

/// State half of [CinematicHomePage]; kept in its own file per the host
/// convention. `movie/popular`, `movie/upcoming`, `movie/top_rated`, then
/// `tv/popular`, `tv/on_the_air`, `tv/top_rated`.
class CinematicHomePageState extends State<CinematicHomePage> {
  late final CinematicApi _api;
  late final CinematicFavoritesStore _store;

  /// `true` while the movie category set (the source's first three lists) is
  /// shown; toggling switches to `tv/popular`, `tv/on_the_air`, `tv/top_rated`.
  bool _isMovieMode = true;

  late final List<CinematicPagingController> _movieLists = CinematicConstants
      .movieCategories
      .map(
        (category) => CinematicPagingController(
          fetchPage: (page) => _api.fetchMovies(page: page, category: category),
        ),
      )
      .toList();

  late final List<CinematicPagingController> _showLists = CinematicConstants
      .showCategories
      .map(
        (category) => CinematicPagingController(
          fetchPage: (page) => _api.fetchShows(page: page, category: category),
        ),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? CinematicApi();
    _store = widget.store ?? CinematicFavoritesStore();
    _store.load();
  }

  /// The source stacked the three movie categories and the three show
  /// categories in one scroll view. This port keeps one `TabBar`/`TabBarView`
  /// pair in sync (the widget asserts they agree on the tab count) and switches
  /// between the movie and show category sets.
  List<String> get _categories => _isMovieMode
      ? CinematicConstants.movieCategories
      : CinematicConstants.showCategories;

  /// The category tabs currently shown (`movie/*` then `tv/*`).
  List<String> get categories => List.unmodifiable(_categories);

  /// Whether the movie category set is the one being shown.
  bool get isMovieMode => _isMovieMode;

  List<CinematicPagingController> get _activeLists =>
      _isMovieMode ? _movieLists : _showLists;

  void _toggleMode() => setState(() => _isMovieMode = !_isMovieMode);

  @override
  void dispose() {
    for (final controller in <CinematicPagingController>[
      ..._movieLists,
      ..._showLists,
    ]) {
      controller.dispose();
    }
    if (widget.store == null) _store.dispose();
    super.dispose();
  }

  void _openSearch() =>
      Navigator.of(context).push(CinematicRoutes.search(store: _store));

  void _openFavorites() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CinematicFavoritesPage(store: _store),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Rebuilt with a new key when the mode changes: the tab count is part of
      // the controller identity, so the tab controller has to be recreated.
      key: ValueKey<bool>(_isMovieMode),
      length: _categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isMovieMode ? 'Movies' : 'TV Shows'),
          actions: <Widget>[
            TextButton(
              onPressed: _toggleMode,
              child: Text(_isMovieMode ? 'TV' : 'Movies'),
            ),
            IconButton(
              onPressed: _openSearch,
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
            IconButton(
              onPressed: _openFavorites,
              icon: const Icon(Icons.favorite),
              tooltip: 'Favorites',
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              for (final category in _categories)
                Tab(text: categoryLabel(category)),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            for (final controller in _activeLists)
              CinematicMediaList(
                controller: controller,
                onItemTap: (item) => Navigator.of(
                  context,
                ).push(CinematicRoutes.mediaDetail(item)),
                favoriteBuilder: (item) =>
                    CinematicFavoriteButton(store: _store, item: item),
              ),
          ],
        ),
      ),
    );
  }

  /// `on_the_air` -> `On the air`; `top_rated` -> `Top rated`.
  static String categoryLabel(String category) {
    final words = category.split('_');
    final buffer = StringBuffer();
    for (var index = 0; index < words.length; index++) {
      if (index > 0) buffer.write(' ');
      final word = words[index];
      buffer.write(
        index == 0 ? '${word[0].toUpperCase()}${word.substring(1)}' : word,
      );
    }
    return buffer.toString();
  }
}
