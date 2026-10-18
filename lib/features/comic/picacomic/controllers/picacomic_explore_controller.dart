import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_registry.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_data.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_part.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:flutter/foundation.dart';

/// Controller of the picacomic home (explore) screen.
///
/// Ports the loading rules of PicaComic's `ExplorePageData` handling in
/// lib/pages/comic_page.dart: `multiPageComicList` pages through
/// `loadPage(page)`, `singlePageWithMultiPart` loads one
/// `loadMultiPart()` payload, `mixed` walks `loadMixed(index)` and accepts both
/// `ExplorePagePart` entries and bare comic lists.
///
/// Not ported: `ExplorePageType.override` (PicaComic handed these to an
/// `overridePageBuilder` widget, which the source contract drops in the host).
class PicacomicExploreController extends ChangeNotifier {
  PicacomicExploreController({List<ComicSource>? sources})
    : sources =
          sources ??
          ComicSourceRegistry.sources
              .where((source) => source.explorePages.isNotEmpty)
              .toList(growable: false);

  final List<ComicSource> sources;

  int _sourceIndex = 0;
  int _explorePageIndex = 0;
  int _page = 1;
  int? _maxPage;
  List<ExplorePagePart> _parts = const [];
  bool _loading = false;
  bool _disposed = false;
  String? _error;

  int get sourceIndex => _sourceIndex;

  ComicSource? get source =>
      sources.isEmpty ? null : sources[_sourceIndex.clamp(0, sources.length - 1)];

  List<ExplorePageData> get explorePages => source?.explorePages ?? const [];

  int get explorePageIndex => _explorePageIndex;

  ExplorePageData? get explorePage => explorePages.isEmpty
      ? null
      : explorePages[_explorePageIndex.clamp(0, explorePages.length - 1)];

  List<ExplorePagePart> get parts => List.unmodifiable(_parts);

  /// Flattened comics, in part order (home screen uses one grid).
  List<BaseComic> get comics => [
    for (final part in _parts) ...part.comics,
  ];

  bool get loading => _loading;

  String? get error => _error;

  int get page => _page;

  bool get hasMore => _maxPage == null || _page < _maxPage!;

  Future<void> selectSource(int index) async {
    if (index == _sourceIndex || index < 0 || index >= sources.length) return;
    _sourceIndex = index;
    _explorePageIndex = 0;
    await reload();
  }

  Future<void> selectExplorePage(int index) async {
    if (index == _explorePageIndex || index < 0 || index >= explorePages.length) {
      return;
    }
    _explorePageIndex = index;
    await reload();
  }

  Future<void> reload() => _load(1, replace: true);

  Future<void> loadMore() {
    if (!hasMore) return Future.value();
    return _load(_page + 1, replace: false);
  }

  Future<void> _load(int page, {required bool replace}) async {
    final data = explorePage;
    if (data == null) {
      _error = 'No explore page';
      _notify();
      return;
    }
    _loading = true;
    _error = null;
    _notify();
    try {
      switch (data.type) {
        case ExplorePageType.multiPageComicList:
          final loader = data.loadPage;
          if (loader == null) {
            _error = '${data.title} has no loadPage';
            break;
          }
          final res = await loader(page);
          if (res.error) {
            _error = res.errorMessageWithoutNull;
            break;
          }
          _parts = [ExplorePagePart(data.title, res.data, null)];
          _maxPage = res.subData is int ? res.subData as int : null;
          _page = page;
        case ExplorePageType.singlePageWithMultiPart:
          final loader = data.loadMultiPart;
          if (loader == null) {
            _error = '${data.title} has no loadMultiPart';
            break;
          }
          final res = await loader();
          if (res.error) {
            _error = res.errorMessageWithoutNull;
            break;
          }
          _parts = res.data;
          _maxPage = 1;
          _page = 1;
        case ExplorePageType.mixed:
          final loader = data.loadMixed;
          if (loader == null) {
            _error = '${data.title} has no loadMixed';
            break;
          }
          final res = await loader(page);
          if (res.error) {
            _error = res.errorMessageWithoutNull;
            break;
          }
          final parts = <ExplorePagePart>[];
          for (final entry in res.data) {
            if (entry is ExplorePagePart) {
              parts.add(entry);
            } else if (entry is List<BaseComic>) {
              parts.add(ExplorePagePart(data.title, entry, null));
            } else if (entry is List) {
              parts.add(
                ExplorePagePart(
                  data.title,
                  entry.whereType<BaseComic>().toList(),
                  null,
                ),
              );
            }
          }
          _parts = parts;
          _maxPage = res.subData is int ? res.subData as int : null;
          _page = page;
        case ExplorePageType.override:
          _error = 'ExplorePageType.override is not ported';
      }
    } catch (e) {
      _error = '$e';
    }
    if (replace && _error != null) {
      _parts = const [];
    }
    _loading = false;
    _notify();
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
