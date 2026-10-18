import 'dart:convert';

/// Lenient JSON coercion used by the hand-written pixiv models.
///
/// The pixiv app-api is inconsistent: ids arrive as ints and strings, some
/// booleans are 0/1, and Dio may hand back either a decoded map or the raw
/// response body. These helpers keep that handling in one place instead of
/// spreading `as` casts through the models.
int pixezInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? pixezIntOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String pixezString(Object? value, {String fallback = ''}) {
  if (value is String) return value;
  if (value == null) return fallback;
  return value.toString();
}

String? pixezStringOrNull(Object? value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

bool pixezBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

DateTime? pixezDateTime(Object? value) {
  if (value is DateTime) return value;
  final raw = pixezStringOrNull(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

Map<String, dynamic> pixezMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> pixezMapList(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return [
    for (final item in value)
      if (item is Map) Map<String, dynamic>.from(item),
  ];
}

List<String> pixezStringList(Object? value) {
  if (value is! List) return const <String>[];
  return [for (final item in value) pixezString(item)];
}

/// Accepts a decoded body, a JSON string, or nothing.
Map<String, dynamic> pixezResponseMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } on FormatException {
      return const <String, dynamic>{};
    }
  }
  return const <String, dynamic>{};
}
