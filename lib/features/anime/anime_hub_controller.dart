import 'package:dashboard/features/anime/anime_category.dart';
import 'package:dashboard/features/anime/anime_episode.dart';
import 'package:dashboard/features/anime/anime_favorite_store.dart';
import 'package:dashboard/features/anime/anime_show.dart';
import 'package:dashboard/features/anime/anime_source.dart';
import 'package:dashboard/features/anime/anime_watch_store.dart';
import 'package:flutter/material.dart';

/// Owns the anime module's remote source, catalogue filters, search results,
/// favourites and watch history.
class AnimeHubController extends ChangeNotifier {
  AnimeHubController({
    AnimeSource? source,
    AnimeFavoriteStore? favorites,
    AnimeWatchStore? history,
  }) : _source = source ?? AnimeSource(),
       _favorites = favorites ?? AnimeFavoriteStore(),
       _history = history ?? AnimeWatchStore();

  final AnimeSource _source;
  final AnimeFavoriteStore _favorites;
  final AnimeWatchStore _history;
  final searchInput = TextEditingController();
  late Future<List<AnimeEpisode>> recent;
  late Future<List<AnimeShow>> catalogue;
  Future<List<AnimeShow>>? searchResults;
  List<AnimeShow> saved = const [];
  AnimeEpisode? lastEpisode;
  Set<String> watched = const {};
  String category = '/subbed-anime-list';
  String catalogueFilter = '';
  bool _disposed = false;

  AnimeFavoriteStore get favoriteStore => _favorites;
  AnimeWatchStore get watchStore => _history;

  AnimeCategory get selectedCategory => AnimeCategory.values.firstWhere(
    (entry) => entry.path == category,
    orElse: () => AnimeCategory.values.first,
  );

  Future<void> load() async {
    recent = _source.recent();
    catalogue = _source.catalogue(category);
    await Future.wait([refreshFavorites(), refreshHistory()]);
  }

  Future<void> refreshFavorites() async {
    final saved = await _favorites.load();
    if (_disposed) return;
    this.saved = saved;
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    final last = await _history.last();
    final watched = await _history.watchedUrls();
    if (_disposed) return;
    lastEpisode = last;
    this.watched = watched;
    notifyListeners();
  }

  Future<void> refreshRecent() async {
    final future = _source.recent();
    recent = future;
    notifyListeners();
    try {
      await future;
    } catch (_) {
      // AsyncContentView renders the failure; pull-to-refresh must not throw.
    }
  }

  void selectCategory(String path) {
    category = path;
    catalogue = _source.catalogue(path);
    notifyListeners();
  }

  void filterCatalogue(String value) {
    catalogueFilter = value.trim();
    notifyListeners();
  }

  void search() {
    final query = searchInput.text.trim();
    if (query.isEmpty) return;
    searchResults = _source.search(query);
    notifyListeners();
  }

  Future<AnimeShow> details(AnimeShow show) => _source.details(show);

  @override
  void dispose() {
    _disposed = true;
    searchInput.dispose();
    _source.dispose();
    super.dispose();
  }
}
