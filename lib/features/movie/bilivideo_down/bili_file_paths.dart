import 'dart:io';

/// Minimal path helpers for this module.
///
/// The host does not depend on `package:path` directly, so joining/splitting
/// paths with the standard `Platform.pathSeparator` avoids adding a dependency
/// for three trivial operations.
class BiliFilePaths {
  const BiliFilePaths._();

  /// Joins [directory] and [name] with the platform separator.
  static String join(String directory, String name) {
    if (directory.isEmpty) return name;
    final last = directory[directory.length - 1];
    if (last == '/' || last == '\\') return '$directory$name';
    return '$directory${Platform.pathSeparator}$name';
  }

  /// Joins three segments; used for `<documents>/databases/<file>`.
  static String joinAll(String first, String second, String third) =>
      join(join(first, second), third);

  /// Parent directory of [path]; `'.'` when there is none.
  static String dirname(String path) {
    final index = _lastSeparator(path);
    if (index < 0) return '.';
    if (index == 0) return path.substring(0, 1);
    return path.substring(0, index);
  }

  /// Final path segment, ignoring a trailing separator.
  static String basename(String path) {
    var end = path.length;
    while (end > 0 && (path[end - 1] == '/' || path[end - 1] == '\\')) {
      end -= 1;
    }
    if (end == 0) return path;
    final index = _lastSeparator(path.substring(0, end));
    return path.substring(index + 1, end);
  }

  static int _lastSeparator(String path) {
    final slash = path.lastIndexOf('/');
    final backslash = path.lastIndexOf('\\');
    return slash > backslash ? slash : backslash;
  }
}
