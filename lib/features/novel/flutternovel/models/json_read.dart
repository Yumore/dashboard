/// Null-tolerant JSON accessors for the flutternovel DTOs.
///
/// The source entities used `json_serializable`, whose generated mappers cast
/// hard (`json['cover'] as String`). Those casts throw as soon as the public
/// zhuishushenqi/dmzj feeds omit an optional key, which they routinely do, so
/// every hand-written mapper in this folder goes through these helpers instead.
/// The JSON *keys* are still exactly the source's `@JsonKey` names.
library;

String? readString(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  if (value == null) return null;
  if (value is String) return value;
  return '$value';
}

int? readInt(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

double? readDouble(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool? readBool(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalised = value.toLowerCase();
    if (normalised == 'true' || normalised == '1') return true;
    if (normalised == 'false' || normalised == '0') return false;
  }
  return null;
}

List<dynamic> readList(Map<String, dynamic>? map, String key) {
  final value = map?[key];
  return value is List ? value : const <dynamic>[];
}

List<String> readStringList(Map<String, dynamic>? map, String key) =>
    readList(map, key)
        .where((element) => element != null)
        .map((element) => '$element')
        .toList();

List<Map<String, dynamic>> readMapList(Map<String, dynamic>? map, String key) =>
    readList(map, key)
        .whereType<Map<dynamic, dynamic>>()
        .map((element) => element.cast<String, dynamic>())
        .toList();
