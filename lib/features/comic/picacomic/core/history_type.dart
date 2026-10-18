/// Ports PicaComic's `HistoryType` from `lib/foundation/history.dart`.
///
/// Built-in sources use stable small integers so persisted history survives
/// registry changes. User-JS sources use the source key's `hashCode`.
final class HistoryType {
  static const HistoryType picacg = HistoryType(0);
  static const HistoryType ehentai = HistoryType(1);
  static const HistoryType jmComic = HistoryType(2);
  static const HistoryType hitomi = HistoryType(3);
  static const HistoryType htmanga = HistoryType(4);
  static const HistoryType nhentai = HistoryType(5);

  static const List<String> _builtInNames = [
    'picacg',
    'ehentai',
    'jm',
    'hitomi',
    'htmanga',
    'nhentai',
  ];

  /// `null` when [value] is not one of the built-in slots.
  static String? nameOf(int value) =>
      (value >= 0 && value < _builtInNames.length)
      ? _builtInNames[value]
      : null;

  /// Restores a persisted integer key verbatim.
  static HistoryType fromKey(int value) => HistoryType(value);

  /// Maps a source key onto its history slot.
  ///
  /// The source used `HistoryType(sourceKey.hashCode)` for `ComicInfoData` and
  /// resolved names through `ComicSource.fromIntKey`, which is equivalent but
  /// makes the persisted integer depend on Dart's string hash. Built-in keys
  /// use their stable slot and only user-JS sources fall back to `hashCode`.
  static HistoryType forSourceKey(String sourceKey) {
    final index = _builtInNames.indexOf(sourceKey);
    return index >= 0 ? HistoryType(index) : HistoryType(sourceKey.hashCode);
  }

  final int value;

  const HistoryType(this.value);

  String get name => nameOf(value) ?? 'Unknown';

  /// True when this type belongs to one of the six built-in sources.
  bool get isBuiltIn => nameOf(value) != null;

  @override
  bool operator ==(Object other) =>
      other is HistoryType && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'HistoryType($value)';
}
