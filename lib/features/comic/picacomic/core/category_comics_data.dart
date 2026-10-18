import 'package:dashboard/features/comic/picacomic/core/category_comics_options.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_typedefs.dart';
import 'package:dashboard/features/comic/picacomic/core/ranking_data.dart';

/// Ports PicaComic's `CategoryComicsData`.
class CategoryComicsData {
  final List<CategoryComicsOptions> options;

  /// [Res.subData] should be the max page, or `null` for no limit.
  final CategoryComicsLoader load;

  final RankingData? rankingData;

  const CategoryComicsData({
    this.options = const [],
    required this.load,
    this.rankingData,
  });

  /// The options that apply to [category], in declaration order.
  List<CategoryComicsOptions> applicableOptions(String category) =>
      options.where((option) => option.appliesTo(category)).toList();
}
