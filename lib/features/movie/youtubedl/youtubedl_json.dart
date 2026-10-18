/// Defensive helpers for the loosely typed InnerTube JSON payloads.
///
/// The public YouTube endpoints return deeply nested maps with optional
/// fields. These helpers keep the response parsers free of repeated casts.
class YoutubeDlJson {
  const YoutubeDlJson._();

  static String asString(Object? value) {
    if (value is String) return value;
    if (value is num) return value.toString();
    return '';
  }

  static int asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  static List<String> asStringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map(asString)
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// Returns the highest resolution thumbnail URL inside a `thumbnail` node.
  static String thumbnailUrl(Object? value) {
    final thumbnails = asMapList(asMap(value)['thumbnails']);
    if (thumbnails.isEmpty) return '';
    return normalizeUrl(asString(thumbnails.last['url']));
  }

  static String normalizeUrl(String raw) {
    if (raw.startsWith('//')) return 'https:$raw';
    return raw;
  }
}
