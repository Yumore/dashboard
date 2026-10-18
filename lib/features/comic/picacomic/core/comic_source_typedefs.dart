import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comment.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';

/// Ports PicaComic's function typedefs from `lib/comic_source/comic_source.dart`.
///
/// Build a comic list; [Res.subData] should be the max page, or `null` when
/// the source has no page limit.
typedef ComicListBuilder = Future<Res<List<BaseComic>>> Function(int page);

typedef LoginFunction = Future<Res<bool>> Function(String, String);

typedef LoadComicFunc = Future<Res<ComicInfoData>> Function(String id);

typedef LoadComicPagesFunc =
    Future<Res<List<String>>> Function(String id, String? ep);

typedef CommentsLoader =
    Future<Res<List<Comment>>> Function(
      String id,
      String? subId,
      int page,
      String? replyTo,
    );

typedef SendCommentFunc =
    Future<Res<bool>> Function(
      String id,
      String? subId,
      String content,
      String? replyTo,
    );

typedef GetImageLoadingConfigFunc =
    Map<String, dynamic> Function(String imageKey, String comicId, String epId);

typedef GetThumbnailLoadingConfigFunc =
    Map<String, dynamic> Function(String imageKey);

/// Category loaders receive the clicked category, its optional parameter, the
/// selected per-source options and the page number.
typedef CategoryComicsLoader =
    Future<Res<List<BaseComic>>> Function(
      String category,
      String? param,
      List<String> options,
      int page,
    );

typedef AddOrDelFavFunc =
    Future<Res<bool>> Function(String comicId, String folderId, bool isAdding);

typedef SearchFunction =
    Future<Res<List<BaseComic>>> Function(
      String keyword,
      int page,
      List<String> searchOption,
    );
