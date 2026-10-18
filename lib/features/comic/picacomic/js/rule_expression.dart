/// Dart-side evaluation of the declarative subset of the user-source rule
/// model: `${var}` request templates and `path[*].field` selectors.
///
/// PicaComic evaluated these expressions inside QuickJS. Anything beyond this
/// subset (arbitrary JS statements, hashing, control flow) is not ported.
class RuleExpression {
  const RuleExpression._();

  /// Replaces `${name}` and `$name` occurrences of [variables].
  ///
  /// Unknown placeholders are left untouched so a mistake is visible in the
  /// resulting URL instead of silently collapsing to an empty string.
  static String interpolate(String template, Map<String, Object?> variables) {
    final braced = template.replaceAllMapped(
      RegExp(r'\$\{([A-Za-z_$][\w$]*)\}'),
      (match) {
        final name = match.group(1)!;
        if (!variables.containsKey(name)) return match.group(0)!;
        return _stringify(variables[name]);
      },
    );
    return braced.replaceAllMapped(RegExp(r'\$([A-Za-z_$][\w$]*)'), (match) {
      final name = match.group(1)!;
      if (!variables.containsKey(name)) return match.group(0)!;
      return _stringify(variables[name]);
    });
  }

  static String _stringify(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Selects values from decoded JSON.
  ///
  /// Segment `[*]` fans out over every element of a list, so
  /// `data.comics[*].title` returns every title as a flat list.
  static List<Object?> select(Object? json, String path) {
    var current = <Object?>[json];
    for (final segment in path.split('.')) {
      if (segment.isEmpty) continue;
      final next = <Object?>[];
      if (segment == '[*]') {
        for (final value in current) {
          if (value is List) next.addAll(value);
        }
      } else if (segment == '[0]') {
        for (final value in current) {
          if (value is List && value.isNotEmpty) next.add(value.first);
        }
      } else {
        for (final value in current) {
          if (value is Map) next.add(value[segment]);
        }
      }
      current = next;
    }
    return current;
  }

  /// Convenience for single-valued paths.
  static Object? first(Object? json, String path) {
    final values = select(json, path);
    return values.isEmpty ? null : values.first;
  }

  /// Convenience for `[*]` paths that must produce strings.
  static List<String> strings(Object? json, String path) {
    final result = <String>[];
    for (final value in select(json, path)) {
      if (value == null) continue;
      result.add(value is String ? value : value.toString());
    }
    return result;
  }
}
