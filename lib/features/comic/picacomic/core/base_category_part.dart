/// Ports PicaComic's `BaseCategoryPart`.
abstract class BaseCategoryPart {
  String get title;

  List<String> get categories;

  List<String>? get categoryParams => null;

  bool get enableRandom;

  /// Passed to [CategoryComicsData.load] as `categoryType`-prefixed category.
  String get categoryType;

  const BaseCategoryPart();
}
