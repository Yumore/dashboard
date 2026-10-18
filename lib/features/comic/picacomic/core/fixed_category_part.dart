import 'package:dashboard/features/comic/picacomic/core/base_category_part.dart';

/// Ports PicaComic's `FixedCategoryPart`.
class FixedCategoryPart extends BaseCategoryPart {
  @override
  final List<String> categories;

  @override
  final String title;

  @override
  final String categoryType;

  @override
  final List<String>? categoryParams;

  @override
  bool get enableRandom => false;

  const FixedCategoryPart(
    this.title,
    this.categories,
    this.categoryType, [
    this.categoryParams,
  ]);
}
