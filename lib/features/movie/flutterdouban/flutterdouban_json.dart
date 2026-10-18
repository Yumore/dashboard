/// Hand-written JSON coercion helpers for the douban v2 payloads.
///
/// The source app (`lib/bean/**`) shipped `json_serializable` codegen output;
/// this host does not carry a code generator, so every mapper reads raw maps.
class FlutterDouBanJson {
  const FlutterDouBanJson._();

  static Map<String, dynamic> asMap(Object? value) =>
      asMapOrNull(value) ?? <String, dynamic>{};

  static Map<String, dynamic>? asMapOrNull(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const [];
    return value
        .map(asMapOrNull)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static List<String> asStringList(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item?.toString() ?? '').toList(growable: false);
  }

  static List<int> asIntList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<num>().map((item) => item.toInt()).toList();
  }

  static int asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? asNullableInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool asBool(Object? value) {
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  static String asString(Object? value) => value?.toString() ?? '';

  static String? asNullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Douban's `rating.details` is `{"1": 1956.0, "2": 3862.0, ...}` — one
  /// bucket per star value. Keys are strings; missing buckets are omitted.
  static Map<int, double> asScoreDetails(Object? value) {
    final map = asMapOrNull(value);
    if (map == null) return const <int, double>{};
    final result = <int, double>{};
    map.forEach((key, item) {
      final star = int.tryParse(key);
      if (star != null) result[star] = asDouble(item);
    });
    return result;
  }
}
