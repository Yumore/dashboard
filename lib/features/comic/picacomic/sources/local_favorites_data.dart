import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/favorite_data.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/data/local_favorites.dart';

/// Ports the local-favourites source contract of
/// PicaComic lib/comic_source/app_build_in_favorites.dart over
/// [LocalFavoritesManager].
///
/// The source exposed local favourites through the favorites *page*, not as a
/// `ComicSource`; this `FavoriteData` is the host-side bridge so the six
/// sources' `FavoriteData` and the local store share one contract.
const int localFavoritesPageSize = 20;

final FavoriteData localFavoriteData = FavoriteData(
  key: 'local',
  title: '本地收藏',
  multiFolder: true,
  allFavoritesId: LocalFavoritesManager.defaultFolder,
  loadComic: (page, [folder]) async {
    final manager = LocalFavoritesManager.instance;
    final comics = manager.getAllComics(
      folder ?? LocalFavoritesManager.defaultFolder,
    );
    final start = (page - 1) * localFavoritesPageSize;
    if (start >= comics.length) {
      return Res<List<BaseComic>>([], subData: manager.folderNames.length);
    }
    final end = (start + localFavoritesPageSize).clamp(0, comics.length);
    return Res<List<BaseComic>>(
      [for (final item in comics.sublist(start, end)) item.toBaseComic()],
      subData: (comics.length / localFavoritesPageSize).ceil(),
    );
  },
  loadFolders: ([comicId]) async {
    final manager = LocalFavoritesManager.instance;
    final folders = <String, String>{
      for (final name in manager.folderNames) name: name,
    };
    if (comicId != null) {
      return Res<Map<String, String>>(
        folders,
        subData: [
          for (final name in manager.folderNames)
            if (manager.getAllComics(name).any((item) => item.target == comicId))
              name,
        ],
      );
    }
    return Res<Map<String, String>>(folders);
  },
  addFolder: (name) async {
    await LocalFavoritesManager.instance.createFolder(name, true);
    return const Res<bool>(true);
  },
  deleteFolder: (name) async {
    await LocalFavoritesManager.instance.deleteFolder(name);
    return const Res<bool>(true);
  },
);
