import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';

/// Ports PicaComic's `FavoriteData`.
class FavoriteData {
  final String key;
  final String title;
  final bool multiFolder;

  final Future<Res<List<BaseComic>>> Function(int page, [String? folder])
  loadComic;

  /// key-id -> value-name. When [comicId] is not null, `Res.subData` holds the
  /// folders the comic already belongs to.
  final Future<Res<Map<String, String>>> Function([String? comicId])?
  loadFolders;

  final Future<Res<bool>> Function(String key)? deleteFolder;

  final Future<Res<bool>> Function(String name)? addFolder;

  final String? allFavoritesId;

  final AddOrDelFavFunc? addOrDeleteFavorite;

  const FavoriteData({
    required this.key,
    required this.title,
    required this.multiFolder,
    required this.loadComic,
    this.loadFolders,
    this.deleteFolder,
    this.addFolder,
    this.allFavoritesId,
    this.addOrDeleteFavorite,
  });
}
