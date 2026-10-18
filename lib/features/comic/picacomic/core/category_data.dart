import 'package:dashboard/features/comic/picacomic/core/base_category_part.dart';
import 'package:dashboard/features/comic/picacomic/core/category_button_data.dart';

/// Ports PicaComic's `CategoryData`.
class CategoryData {
  /// Title displayed on the category tab.
  final String title;

  final List<BaseCategoryPart> categories;

  final bool enableRankingPage;

  final String key;

  final List<CategoryButtonData> buttons;

  const CategoryData({
    required this.title,
    required this.categories,
    required this.enableRankingPage,
    required this.key,
    this.buttons = const [],
  });
}
