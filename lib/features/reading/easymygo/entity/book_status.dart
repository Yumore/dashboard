/// Ported from `MangaStatus` / `NovelStatus` in the respective `*_enum.dart`.
enum BookStatus {
  ongoing,
  complete,
  unknown;

  static BookStatus fromName(String? name) {
    for (final value in BookStatus.values) {
      if (value.name == name) {
        return value;
      }
    }
    return BookStatus.unknown;
  }
}

/// Ported from `MangaUpdateStrategy` / `NovelUpdateStrategy`.
enum BookUpdateStrategy {
  always,
  onlyStrict,
  never;

  static BookUpdateStrategy fromName(String? name) {
    for (final value in BookUpdateStrategy.values) {
      if (value.name == name) {
        return value;
      }
    }
    return BookUpdateStrategy.always;
  }
}
