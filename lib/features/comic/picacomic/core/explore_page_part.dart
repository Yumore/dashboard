import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';

/// Ports PicaComic's `ExplorePagePart`.
class ExplorePagePart {
  final String title;

  final List<BaseComic> comics;

  /// When not `null`, the part shows a "view more" button. Format:
  /// `search:keyword` or `category:name`, optionally `@param` on the category
  /// form.
  final String? viewMore;

  const ExplorePagePart(this.title, this.comics, this.viewMore);
}
