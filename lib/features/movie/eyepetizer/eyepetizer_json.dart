/// Hand-written JSON coercion helpers for the 开眼 payloads.
///
/// The source app was pre-null-safety and read fields directly off a decoded
/// `Map` (`json['playUrl']`), so a missing key became `null` and blew up later in
/// a widget. The port keeps every accessor total: a missing or wrongly-typed
/// value degrades to a zero value instead of throwing.
class EyepetizerJson {
  const EyepetizerJson._();

  static Map<String, dynamic> asMap(Object? value) =>
      asMapOrNull(value) ?? <String, dynamic>{};

  static Map<String, dynamic>? asMapOrNull(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .map(asMapOrNull)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  static List<Object?> asList(Object? value) =>
      value is List ? List<Object?>.of(value) : const <Object?>[];

  static List<String> asStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value.map((item) => item?.toString() ?? '').toList(growable: false);
  }

  static int asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? asNullableInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
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
}
