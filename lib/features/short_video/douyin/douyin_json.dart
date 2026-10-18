/// 抖音接口的宽松 JSON 读取工具。
///
/// 源工程 `flutter_app/lib/models/Tiktok.dart` 与
/// `flutter_app_cn/lib/models/Douyin.Dart` 都直接强转字段，但线上响应里同一个
/// 字段可能是数字或字符串（如 `rank`、`hasMore`、`digg_count`）。宿主把容错
/// 收敛到这里，解析器保持一行一个字段。
class DouyinJson {
  DouyinJson._();

  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static List<Object?> asList(Object? value) {
    if (value is List) {
      return value;
    }
    return const <Object?>[];
  }

  static String asString(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static int asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static bool asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final text = value.trim().toLowerCase();
      return text == 'true' || text == '1';
    }
    return false;
  }

  /// 取 `url_list` 这类字符串列表里的首个非空元素。
  static String firstString(Object? value) {
    for (final item in asList(value)) {
      final text = asString(item);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  static List<String> stringList(Object? value) {
    return asList(value)
        .map(asString)
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
