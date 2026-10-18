import 'dart:collection';

/// Ports PicaComic's `CategoryComicsOptions`.
class CategoryComicsOptions {
  /// key is sent to the source, value is displayed to the user.
  /// The first entry is the default.
  final LinkedHashMap<String, String> options;

  /// Hidden when the clicked category is in this list.
  final List<String> notShowWhen;

  /// Only shown when the clicked category is in this list, when not `null`.
  final List<String>? showWhen;

  const CategoryComicsOptions({
    required this.options,
    this.notShowWhen = const [],
    this.showWhen,
  });

  /// Whether these options apply to [category].
  bool appliesTo(String category) {
    if (notShowWhen.contains(category)) return false;
    if (showWhen != null && !showWhen!.contains(category)) return false;
    return true;
  }

  String get defaultValue => options.keys.first;
}
