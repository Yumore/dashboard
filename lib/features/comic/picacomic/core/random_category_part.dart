import 'dart:math' as math;

import 'package:dashboard/features/comic/picacomic/core/base_category_part.dart';

/// Ports PicaComic's `RandomCategoryPart`: shows a random slice of [tags].
class RandomCategoryPart extends BaseCategoryPart {
  final List<String> tags;

  final int randomNumber;

  @override
  final String title;

  @override
  final String categoryType;

  @override
  bool get enableRandom => true;

  const RandomCategoryPart(
    this.title,
    this.tags,
    this.randomNumber,
    this.categoryType,
  );

  @override
  List<String> get categories {
    if (randomNumber >= tags.length) return tags;
    return tags.sublist(math.Random().nextInt(tags.length - randomNumber));
  }
}
