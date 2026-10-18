import 'dart:math' as math;

import 'package:dashboard/features/comic/picacomic/core/base_category_part.dart';

/// Ports PicaComic's `RandomCategoryPartWithRuntimeData`.
class RandomCategoryPartWithRuntimeData extends BaseCategoryPart {
  final Iterable<String> Function() loadTags;

  final int randomNumber;

  @override
  final String title;

  @override
  final String categoryType;

  static final math.Random _random = math.Random();

  RandomCategoryPartWithRuntimeData(
    this.title,
    this.loadTags,
    this.randomNumber,
    this.categoryType,
  );

  @override
  bool get enableRandom => true;

  @override
  List<String> get categories {
    final tags = loadTags().toList();
    if (randomNumber >= tags.length) return tags;
    final start = _random.nextInt(tags.length - randomNumber);
    return tags.sublist(start, start + randomNumber);
  }
}
