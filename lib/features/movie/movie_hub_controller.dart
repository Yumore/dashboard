import 'package:dashboard/features/movie/movie_endpoint_store.dart';
import 'package:dashboard/features/movie/movie_favorites_store.dart';
import 'package:dashboard/features/movie/movie_item.dart';
import 'package:dashboard/features/movie/movie_source.dart';
import 'package:flutter/material.dart';

/// Owns the movie module's backend connection, discovery results and watch
/// list. The page and the tabs only render this state.
class MovieHubController extends ChangeNotifier {
  MovieHubController({
    MovieEndpointStore? endpointStore,
    MovieFavoritesStore? favoritesStore,
  }) : _endpointStore = endpointStore ?? MovieEndpointStore(),
       _favoritesStore = favoritesStore ?? MovieFavoritesStore();

  final MovieEndpointStore _endpointStore;
  final MovieFavoritesStore _favoritesStore;
  final endpointInput = TextEditingController();
  final searchInput = TextEditingController();
  MovieSource? _source;
  Future<List<MovieItem>>? _results;
  List<MovieItem> _favorites = const [];
  String _classify = '电影';
  bool _disposed = false;

  Future<List<MovieItem>>? get results => _results;
  List<MovieItem> get favorites => _favorites;
  String get classify => _classify;
  bool get connected => _source != null;

  /// Restores the saved endpoint and watch list, then reconnects when an
  /// endpoint was stored.
  Future<String?> load() async {
    final endpoint = await _endpointStore.load();
    final favorites = await _favoritesStore.load();
    if (_disposed) return null;
    endpointInput.text = endpoint ?? '';
    _favorites = favorites;
    notifyListeners();
    if (endpoint != null) return connect();
    return null;
  }

  /// Connects to the endpoint in [endpointInput]; returns an error message to
  /// show in a snack bar, or null on success.
  Future<String?> connect() async {
    final endpoint = Uri.tryParse(endpointInput.text.trim());
    if (endpoint == null ||
        !<String>['http', 'https'].contains(endpoint.scheme)) {
      return '请输入 HTTP/HTTPS 影视服务地址';
    }
    await _endpointStore.save(endpoint.toString());
    if (_disposed) return null;
    _source?.dispose();
    _source = MovieSource(endpoint);
    _results = _source!.recommendations(_classify);
    notifyListeners();
    return null;
  }

  void classifyAs(String value) {
    final source = _source;
    _classify = value;
    if (source != null) _results = source.recommendations(value);
    notifyListeners();
  }

  void search() {
    final source = _source;
    final query = searchInput.text.trim();
    if (query.isEmpty || source == null) return;
    _results = source.search(query);
    notifyListeners();
  }

  Future<void> toggleFavorite(MovieItem item) async {
    await _favoritesStore.toggle(item);
    final favorites = await _favoritesStore.load();
    if (_disposed) return;
    _favorites = favorites;
    notifyListeners();
  }

  /// Endpoint used to load episodic details for [item].
  MovieSource? detailsSource(MovieItem item) {
    final endpoint =
        item.serviceEndpoint ?? Uri.tryParse(endpointInput.text.trim());
    if (endpoint == null ||
        !<String>['http', 'https'].contains(endpoint.scheme)) {
      return null;
    }
    return MovieSource(endpoint);
  }

  @override
  void dispose() {
    _disposed = true;
    _source?.dispose();
    endpointInput.dispose();
    searchInput.dispose();
    super.dispose();
  }
}
