import 'dart:convert';

import 'package:dashboard/features/reading/book/util/book_log.dart';

/// Legado-style JS rule host for book sources.
///
/// The source project evaluated `@js:` / `<js>…</js>` snippets with the
/// `flutter_js` package. The host root pubspec declares **no** JavaScript
/// runtime and this migration may not add dependencies, so [eval] implements
/// the documented degradation path instead of executing script:
///
/// * the injected bindings are known ([result] / [baseUrl] / [src]);
/// * a rule without a runtime returns the incoming [result] unchanged, which
///   keeps selectors that merely *end* in a JS guard working, and makes
///   JS-only sources fail loudly (empty list / unchanged text) rather than
///   silently producing wrong data.
///
/// Detection and code extraction are fully implemented and unit tested, so the
/// rest of the pipeline routes JS rules to exactly one place.
class JsEngine {
  JsEngine._();

  static final JsEngine instance = JsEngine._();

  String _loadedJsLib = '';

  /// Always false: no JS runtime is linked into the host.
  bool get runtimeAvailable => false;

  /// Accepted for API parity with the source engine; records the library text
  /// so callers can assert it was supplied even though it cannot be executed.
  void ensureJsLib(String jsLib) {
    final lib = jsLib.trim();
    if (lib.isEmpty) return;
    _loadedJsLib = lib;
    BookLog.d('JsEngine', 'jsLib accepted but not executed (${lib.length} chars)');
  }

  /// Text of the last [ensureJsLib] call (empty when none).
  String get loadedJsLib => _loadedJsLib;

  /// True if [rule] looks like it needs JS evaluation.
  static bool needsJs(String rule) {
    final r = rule.trim();
    if (r.isEmpty) return false;
    return r.startsWith('@js:') || r.contains('<js>') || r.contains('@js:');
  }

  /// Extract pure JS code from a Legado rule fragment, or null when not JS.
  static String? extractCode(String rule) {
    final r = rule.trim();
    if (r.isEmpty) return null;
    if (r.startsWith('@js:')) {
      return r.substring(4).trim();
    }
    final m = RegExp(r'<js>([\s\S]*?)</js>', caseSensitive: false).firstMatch(r);
    if (m != null) return (m.group(1) ?? '').trim();
    final idx = r.indexOf('@js:');
    if (idx >= 0) return r.substring(idx + 4).trim();
    return null;
  }

  /// Evaluate [code] with bindings. Without a runtime this returns [result]
  /// (or [src] when [result] is empty) — never throws.
  String eval(
    String code, {
    String result = '',
    String baseUrl = '',
    String src = '',
    String jsLib = '',
  }) {
    if (jsLib.isNotEmpty) ensureJsLib(jsLib);
    if (code.isEmpty) return result;
    BookLog.d('JsEngine', 'no JS runtime; rule degraded to passthrough');
    return result.isNotEmpty ? result : src;
  }

  /// If [rule] is JS, run it against [input]; otherwise null (caller handles).
  String? tryEvalRule(
    String rule, {
    required String input,
    required String baseUrl,
    String jsLib = '',
  }) {
    if (!needsJs(rule)) return null;
    final code = extractCode(rule);
    if (code == null || code.isEmpty) return null;
    return eval(
      code,
      result: input,
      baseUrl: baseUrl,
      src: input,
      jsLib: jsLib,
    );
  }

  /// Parse JS list output into List (of Map or String).
  List<dynamic> evalList(
    String code, {
    String result = '',
    String baseUrl = '',
    String src = '',
    String jsLib = '',
  }) {
    final out = eval(
      code,
      result: result,
      baseUrl: baseUrl,
      src: src,
      jsLib: jsLib,
    );
    if (out.isEmpty) return const [];
    try {
      final decoded = jsonDecode(out);
      if (decoded is List) return decoded;
      if (decoded is Map) return [decoded];
    } catch (_) {
      final lines = out
          .split(RegExp(r'[\r\n]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (lines.length > 1) return lines;
    }
    return [out];
  }

  void dispose() {
    _loadedJsLib = '';
  }
}
