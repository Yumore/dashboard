import 'dart:collection';

/// Ports PicaComic's `SearchOptions`.
class SearchOptions {
  /// key is sent to the source, value is displayed to the user.
  final LinkedHashMap<String, String> options;

  final String label;

  const SearchOptions(this.options, this.label);

  String get defaultValue => options.keys.first;

  const SearchOptions.named({required this.options, required this.label});
}
