import 'dart:math';

/// Standalone replacement for `package:collection` helpers.
///
/// The host pubspec does not declare `collection`, so the few helpers the
/// tsdm parsers need are hand-written here.
extension TsdmIterableExtension<T> on Iterable<T> {
  /// The first element satisfying [test], or null.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  /// The element at [index], or null when out of range.
  T? elementAtOrNull(int index) {
    if (index < 0) {
      return null;
    }
    var i = 0;
    for (final element in this) {
      if (i == index) {
        return element;
      }
      i++;
    }
    return null;
  }

  /// The last element, or null when empty.
  T? get lastOrNull {
    if (isEmpty) {
      return null;
    }
    T? ret;
    for (final element in this) {
      ret = element;
    }
    return ret;
  }
}

/// Standalone replacement for `package:collection`'s `slices`.
extension TsdmListExtension<T> on List<T> {
  /// Group the list into chunks of [size] elements.
  Iterable<List<T>> slices(int size) sync* {
    if (size <= 0) {
      return;
    }
    for (var i = 0; i < length; i += size) {
      yield sublist(i, min(i + size, length));
    }
  }
}
