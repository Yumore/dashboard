/// Hand-written JSON coercion helpers (the source relied on json_serializable
/// codegen, which this host does not carry).
class MovieAppJson {
  const MovieAppJson._();

  static int asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String asString(Object? value) => value?.toString() ?? '';

  static String? asNullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static List<int> asIntList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<num>().map((item) => item.toInt()).toList();
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => row.map((key, item) => MapEntry(key.toString(), item)))
        .toList();
  }
}
