import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_part.dart';
import 'package:dashboard/features/comic/picacomic/core/explore_page_type.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';

/// Ports PicaComic's `ExplorePageData`.
class ExplorePageData {
  final String title;

  final ExplorePageType type;

  final ComicListBuilder? loadPage;

  final Future<Res<List<ExplorePagePart>>> Function()? loadMultiPart;

  /// A `List` of `List<BaseComic>` or `ExplorePagePart`, by index.
  final Future<Res<List<Object>>> Function(int index)? loadMixed;

  const ExplorePageData({
    required this.title,
    required this.type,
    this.loadPage,
    this.loadMultiPart,
    this.loadMixed,
  });
}
