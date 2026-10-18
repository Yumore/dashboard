import 'package:dashboard/features/movie/fluttercinematic/cinematic_media_item.dart';
import 'package:flutter/foundation.dart';

/// Paging controller behind `CinematicMediaList`.
///
/// The source `MediaListState` held `isLoading`, `isError`, `page` and
/// `items`, appended a new page whenever the `ScrollController` passed 300px
/// (2500px for the similar-media row), and stopped when `isLoading` or `!hasMore`.
/// The threshold is kept here; `page` starts at 1 and each successful non-final
/// page advances it, so `fetchMovies(page: controller.page)` walks the TMDb
/// pager.
class CinematicPagingController extends ChangeNotifier {
  CinematicPagingController({
    required this.fetchPage,
    this.loadMoreThreshold = 300,
    this.pageSize = 20,
  });

  final Future<List<CinematicMediaItem>> Function(int page) fetchPage;
  final double loadMoreThreshold;
  final int pageSize;

  final List<CinematicMediaItem> _items = <CinematicMediaItem>[];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  Object? _error;

  List<CinematicMediaItem> get items => List.unmodifiable(_items);
  int get page => _page;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  /// Source `getData()`.
  Future<void> loadInitial() => fetchNextPage();

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await fetchPage(_page);
      _items.addAll(fetched);
      // A short page means the last TMDb page has been reached.
      if (fetched.length < pageSize) {
        _hasMore = false;
      } else {
        _page = _page + 1;
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
