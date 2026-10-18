import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_registry.dart';
import 'package:dashboard/features/comic/picacomic/data/local_favorites.dart';
import 'package:flutter/foundation.dart';

/// Controller of the picacomic comic detail screen.
///
/// Ports the loading path of PicaComic lib/pages/comic_page.dart: the detail
/// screen asks the source for `loadComicInfo(id)` and renders
/// `ComicInfoData.chapters`; the local favourites store decides the favourite
/// state (PicaComic's `LocalFavoritesManager.isFavorite`), while a source's
/// server-side favourite flag only seeds the initial value.
class PicacomicDetailController extends ChangeNotifier {
  PicacomicDetailController({
    required this.sourceKey,
    required this.comicId,
    LocalFavoritesManager? favorites,
  }) : favorites = favorites ?? LocalFavoritesManager.instance;

  final String sourceKey;
  final String comicId;
  final LocalFavoritesManager favorites;

  ComicInfoData? _comic;
  bool _loading = false;
  bool _disposed = false;
  bool _favorite = false;
  String? _error;

  ComicInfoData? get comic => _comic;

  bool get loading => _loading;

  String? get error => _error;

  bool get favorite => _favorite;

  ComicSource? get source => ComicSourceRegistry.find(sourceKey);

  /// Chapter id -> chapter name, in source order.
  List<MapEntry<String, String>> get chapters =>
      (_comic?.chapters ?? const <String, String>{}).entries.toList();

  /// The source's favorite flag, when the source reports one.
  bool get serverFavorite => _comic?.isFavorite ?? false;

  Future<void> load() async {
    _loading = true;
    _error = null;
    _notify();
    final src = source;
    final loader = src?.loadComicInfo;
    if (loader == null) {
      _error = 'Unknown comic source: $sourceKey';
      _loading = false;
      _notify();
      return;
    }
    try {
      final res = await loader(comicId);
      if (res.error) {
        _error = res.errorMessageWithoutNull;
      } else {
        _comic = res.data;
        _favorite =
            favorites.isFavorite(comicId, _favoriteType) ||
            (_comic?.isFavorite ?? false);
      }
    } catch (e) {
      _error = '$e';
    }
    _loading = false;
    _notify();
  }

  /// Toggles the local favourite row for the current comic.
  Future<void> toggleFavorite() async {
    final type = _favoriteType;
    const folder = LocalFavoritesManager.defaultFolder;
    if (favorites.isFavorite(comicId, type)) {
      for (final name in favorites.find(comicId, type)) {
        await favorites.removeComic(name, comicId, type.key);
      }
      _favorite = false;
    } else {
      final comic = _comic;
      if (comic == null) return;
      await favorites.addComic(
        folder,
        FavoriteItem.fromComicInfo(comic, type: type),
      );
      _favorite = true;
    }
    _notify();
  }

  FavoriteType get _favoriteType =>
      FavoriteType.fromSourceKey(sourceKey, source?.intKey);

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
