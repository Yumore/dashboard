/// 人人影视响应的手写 JSON 取值助手。
///
/// 源工程是 pre-null-safety 代码，直接从 `res.data['data']` 上取字段
/// （`Api.search`、`ResInfoPage.buildBody` 等），少一个 key 就会在 widget 里
/// 抛异常。移植版把每个取值都做成全函数：缺失或类型不符时退化成零值。
class YyetsJson {
  const YyetsJson._();

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
    return value
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// 源工程的 `score`、`dateline` 有时是数字有时是字符串，统一成 int。
  static int asInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static int? asNullableInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '');
  }

  static double asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  /// 源工程的 `play` / `status` 字段混用 `1`、`"1"`、`true`。
  static bool asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == '1' || text == 'true';
  }

  static String asString(Object? value) => value?.toString() ?? '';

  /// 空串按缺失处理——源工程多处 `nullEmptyElse(x, "无时间")`。
  static String? asNullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
