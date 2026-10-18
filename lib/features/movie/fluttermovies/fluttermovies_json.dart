/// 宽松 JSON 取值助手：CMS 同一个字段在 int / string 之间摇摆。
class FlutterMoviesJson {
  const FlutterMoviesJson._();

  static int asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static String asString(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    return '$value';
  }

  /// 空串按缺失处理。
  static String? asOptionalString(Object? value) {
    final text = asString(value).trim();
    return text.isEmpty ? null : text;
  }

  static List<dynamic> asList(Object? value) =>
      value is List ? value : const <dynamic>[];

  static Map<String, dynamic> asMap(Object? value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, item) => MapEntry('$key', item));
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map>().map(asMap).toList();
  }
}
