import 'package:flutter/foundation.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_list_mode.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic_sort_type.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comics_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_initial.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_search_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';
import 'package:dashboard/features/comic/hakacomic/haka_user_favorite_payload.dart';

/// Paged comic list shared by the category, favourites and search screens.
///
/// The load-more rule is upstream's: a list is exhausted once the returned
/// `page` reaches the envelope's `pages`
/// (`haka_comic/lib/views/categories/categories.dart`).
class HakaComicListController extends ChangeNotifier {
  HakaComicListController({
    required this.repository,
    required this.mode,
    this.category,
    this.keyword,
    this.categories = const {},
    this.sort = HakaComicSortType.dd,
  });

  /// `GET comics?c=<category>`.
  HakaComicListController.category({
    required HakaRepository repository,
    required String category,
    HakaComicSortType sort = HakaComicSortType.dd,
  }) : this(
         repository: repository,
         mode: HakaComicListMode.category,
         category: category,
         sort: sort,
       );

  /// `POST comics/advanced-search`.
  HakaComicListController.search({
    required HakaRepository repository,
    required String keyword,
    HakaComicSortType sort = HakaComicSortType.dd,
    Set<String> categories = const {},
  }) : this(
         repository: repository,
         mode: HakaComicListMode.search,
         keyword: keyword,
         sort: sort,
         categories: categories,
       );

  /// `GET users/favourite`.
  HakaComicListController.favourites({
    required HakaRepository repository,
    HakaComicSortType sort = HakaComicSortType.dd,
  }) : this(
         repository: repository,
         mode: HakaComicListMode.favourites,
         sort: sort,
       );

  final HakaRepository repository;

  final HakaComicListMode mode;

  final String? category;

  final String? keyword;

  final Set<String> categories;

  final HakaComicSortType sort;

  final List<HakaComicBase> _items = [];

  HakaRequestState<List<HakaComicBase>> _state =
      const HakaInitial<List<HakaComicBase>>();

  /// 1-based index of the page currently held; `0` before the first load.
  int _page = 0;

  int _pages = 1;

  bool _loadingMore = false;

  Object? _moreError;

  bool _disposed = false;

  HakaRequestState<List<HakaComicBase>> get state => _state;

  List<HakaComicBase> get items => List.unmodifiable(_items);

  int get page => _page;

  int get pages => _pages;

  bool get isLoadingMore => _loadingMore;

  Object? get moreError => _moreError;

  /// True while another page is available.
  bool get hasMore => _page < _pages;

  /// First load or an explicit refresh; leaves previous data as loading payload.
  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      _page = 0;
      _pages = 1;
      _items.clear();
    }
    _state = HakaLoading<List<HakaComicBase>>(
      _items.isEmpty ? null : List.unmodifiable(_items),
    );
    _notify();
    try {
      final result = await _fetch(_page + 1);
      _page = result.page;
      _pages = result.pages;
      _items
        ..clear()
        ..addAll(result.docs);
      _state = HakaSuccess<List<HakaComicBase>>(List.unmodifiable(_items));
    } catch (error) {
      _state = HakaFailure<List<HakaComicBase>>(error);
    }
    _notify();
  }

  /// Appends the next page. No-op when exhausted or already loading.
  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _loadingMore = true;
    _moreError = null;
    _notify();
    try {
      final result = await _fetch(_page + 1);
      _page = result.page;
      _pages = result.pages;
      _items.addAll(result.docs);
      _state = HakaSuccess<List<HakaComicBase>>(List.unmodifiable(_items));
    } catch (error) {
      _moreError = error;
    }
    _loadingMore = false;
    _notify();
  }

  Future<void> refresh() => load(refresh: true);

  Future<HakaComicPage> _fetch(int page) async {
    switch (mode) {
      case HakaComicListMode.category:
        final comics = await repository.fetchComics(
          HakaComicsPayload(page: page, c: category, s: sort),
        );
        return HakaComicPage(
          docs: comics.docs,
          page: comics.page,
          pages: comics.pages,
        );
      case HakaComicListMode.favourites:
        final comics = await repository.fetchFavoriteComics(
          HakaUserFavoritePayload(page: page, sort: sort),
        );
        return HakaComicPage(
          docs: comics.docs,
          page: comics.page,
          pages: comics.pages,
        );
      case HakaComicListMode.search:
        final comics = await repository.searchComics(
          HakaSearchPayload(
            keyword: keyword ?? '',
            page: page,
            sort: sort,
            categories: categories,
          ),
        );
        return HakaComicPage(
          docs: comics.docs,
          page: comics.page,
          pages: comics.pages,
        );
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
