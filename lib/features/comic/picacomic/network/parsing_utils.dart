/// Small string/iterable helpers PicaComic had in lib/tools/extensions.dart
/// and via package:collection, re-implemented so the port needs no new
/// dependency.
extension StringParsingUtils on String {
  /// lib/tools/extensions.dart:44 `nums` — keeps every digit.
  String get nums {
    final matches = RegExp(r'\d+').allMatches(this);
    if (matches.isEmpty) return '';
    return matches.map((match) => match.group(0)).join();
  }

  /// lib/tools/extensions.dart:31 `removeAllBlank`.
  String get removeAllBlank =>
      replaceAll('\n', '').replaceAll(' ', '').replaceAll('\t', '');

  /// lib/tools/extensions.dart:85 `isNum`.
  bool get isNum => double.tryParse(this) != null;

  /// lib/tools/extensions.dart `isURL`.
  bool get isURL {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}

extension IterableParsingUtils<E> on Iterable<E> {
  E? atOrNull(int index) {
    if (index < 0) return null;
    var i = 0;
    for (final element in this) {
      if (i == index) return element;
      i++;
    }
    return null;
  }

  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? get lastOrNull {
    E? last;
    for (final element in this) {
      last = element;
    }
    return last;
  }
}
