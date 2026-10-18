/// Defensive JSON traversal helpers shared by the source parsers.
///
/// Paths are dot separated and accept list indices, e.g.
/// `jsonAt(payload, 'data.comics.0.title')`.
dynamic jsonAt(Object? json, String path) {
  dynamic current = json;
  for (final segment in path.split('.')) {
    if (segment.isEmpty) continue;
    if (current is Map) {
      current = current[segment];
    } else if (current is List) {
      final index = int.tryParse(segment);
      if (index == null || index < 0 || index >= current.length) return null;
      current = current[index];
    } else {
      return null;
    }
  }
  return current;
}

String jsonString(Object? json, String path, {String fallback = ''}) {
  final value = jsonAt(json, path);
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

String? jsonStringOrNull(Object? json, String path) {
  final value = jsonAt(json, path);
  if (value == null) return null;
  return value is String ? value : value.toString();
}

int jsonInt(Object? json, String path, {int fallback = 0}) {
  final value = jsonAt(json, path);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double jsonDouble(Object? json, String path, {double fallback = 0}) {
  final value = jsonAt(json, path);
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool jsonBool(Object? json, String path, {bool fallback = false}) {
  final value = jsonAt(json, path);
  if (value is bool) return value;
  if (value is String) return value == 'true' || value == '1';
  if (value is num) return value != 0;
  return fallback;
}

List<dynamic> jsonList(Object? json, String path) {
  final value = jsonAt(json, path);
  return value is List ? value : const [];
}

/// Maps every entry of the list at [path] through [convert], skipping entries
/// that do not convert (mirrors PicaComic's `.where(...)` filters).
List<T> jsonMapList<T>(
  Object? json,
  String path,
  T Function(Map<String, dynamic> item) convert,
) {
  final result = <T>[];
  for (final item in jsonList(json, path)) {
    if (item is! Map) continue;
    try {
      result.add(convert(Map<String, dynamic>.from(item)));
    } catch (_) {
      continue;
    }
  }
  return result;
}

List<String> jsonStringList(Object? json, String path) {
  final result = <String>[];
  for (final item in jsonList(json, path)) {
    if (item == null) continue;
    result.add(item is String ? item : item.toString());
  }
  return result;
}

/// Reads the comic list inside PicaComic's paging envelope plus its `pages`
/// field. Returns the items alongside the max page discovered.
({List<Map<String, dynamic>> docs, int? maxPage}) pagedDocs(
  Object? json, {
  required String docsPath,
  String pagesPath = 'data.pages',
}) {
  final docs = <Map<String, dynamic>>[];
  for (final item in jsonList(json, docsPath)) {
    if (item is Map) docs.add(Map<String, dynamic>.from(item));
  }
  final pages = jsonAt(json, pagesPath);
  int? maxPage;
  if (pages is int) {
    maxPage = pages;
  } else if (pages is String) {
    maxPage = int.tryParse(pages);
  }
  return (docs: docs, maxPage: maxPage);
}
