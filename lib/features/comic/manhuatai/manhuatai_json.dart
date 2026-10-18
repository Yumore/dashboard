/// Lenient JSON coercion helpers.
///
/// The source models relied on `json_serializable`, which would throw when a
/// field arrived with a different runtime type. The manhuatai backend is known
/// to send the same field as `int` in one payload and `String` in another (for
/// example `total_view_num`, `score`, `rise_rank`), so this port normalises
/// defensively instead of crashing the screen.
///
/// This replaces code generation: no `.g.dart` files, no `build_runner`.
class ManhuataiJson {
  const ManhuataiJson._();

  /// Returns [value] as a string-keyed map, or an empty map.
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return <String, dynamic>{};
  }

  /// Returns [value] as a list of string-keyed maps, skipping non-map entries.
  static List<Map<String, dynamic>> maps(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> item) => map(item))
        .toList();
  }

  /// Returns [value] as an int, accepting numeric strings.
  static int asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    return 0;
  }

  /// Returns [value] as a double, accepting numeric strings.
  static double asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  /// Returns [value] as a String; never null.
  ///
  /// [fallback] is returned when the value is absent (null).
  static String asString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      return value;
    }
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  /// Alias of [asString] used where the source field was declared `dynamic`
  /// (the backend may send either an int or a String).
  static String asDynamicString(dynamic value) => asString(value);

  /// Returns [value] as a bool, accepting `0`/`1` and `"true"`/`"false"`.
  static bool asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalised = value.trim().toLowerCase();
      return normalised == 'true' || normalised == '1';
    }
    return false;
  }

  /// Returns [value] as a `List<String>`; never null.
  static List<String> asStringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }
    return value.map(asString).toList();
  }

  /// Returns [value] as a `List<int>`; never null.
  static List<int> asIntList(dynamic value) {
    if (value is! List) {
      return <int>[];
    }
    return value.map(asInt).toList();
  }
}
