import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Host-side replacement for the source project's `AppLog`.
///
/// Keeps an in-memory ring buffer (bounded by [maxEntries]) plus debug-console
/// output so book-source fetches and parsers stay diagnosable without pulling
/// in a logging package that the root pubspec does not declare.
class BookLog {
  BookLog._();

  static int maxEntries = 500;
  static final ListQueue<String> _buffer = ListQueue<String>();

  static void d(String tag, String msg) => _write('D', tag, msg);

  static void i(String tag, String msg) => _write('I', tag, msg);

  static void w(String tag, String msg, {Object? error}) =>
      _write('W', tag, error == null ? msg : '$msg error=$error');

  static void e(
    String tag,
    String msg, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    var line = msg;
    if (error != null) line = '$line error=$error';
    if (stackTrace != null) line = '$line\n$stackTrace';
    _write('E', tag, line);
  }

  static List<String> get entries => List<String>.unmodifiable(_buffer);

  static String dump() => entries.join('\n');

  static void clear() => _buffer.clear();

  static void _write(String level, String tag, String msg) {
    final line = '[$level][$tag] $msg';
    _buffer.addLast(line);
    while (_buffer.length > maxEntries) {
      _buffer.removeFirst();
    }
    if (kDebugMode) {
      debugPrint(line);
    }
  }
}
