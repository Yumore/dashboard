import 'dart:convert';

import 'package:dashboard/features/movie/eyepetizer_flutter/eyepetizer_flutter_json.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `lib/utils/prfs_util.dart`.
///
/// The source switched on the *type parameter* (`switch (T)`) to pick the
/// right `setX`, which only compiled pre-null-safety; the port uses `if`
/// comparisons with the same effect. Everything else is the source's contract:
/// objects are stored as one JSON string, and a null object stores the empty
/// string.
class EyepetizerFlutterPrefsUtil {
  const EyepetizerFlutterPrefsUtil._();

  static Future<void> save<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (T == String) {
      await prefs.setString(key, value as String);
    } else if (T == int) {
      await prefs.setInt(key, value as int);
    } else if (T == bool) {
      await prefs.setBool(key, value as bool);
    } else if (T == double) {
      await prefs.setDouble(key, value as double);
    }
  }

  static Future<Object?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> putObject(String key, Object? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value == null ? '' : jsonEncode(value));
  }

  static Future<T?> getObj<T>(
    String key,
    T Function(Map<String, dynamic> json) factory, {
    T? defaultValue,
  }) async {
    final map = await getObject(key);
    if (map == null) return defaultValue;
    return factory(map);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return null;
    final decoded = jsonDecode(value);
    return decoded is Map ? EyepetizerFlutterJson.asMap(decoded) : null;
  }

  static Future<void> putObjectList(String key, List<Object?> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      values.map((value) => jsonEncode(value)).toList(),
    );
  }

  /// The source declared this one non-`async` while awaiting an async call;
  /// the port returns a future, which is the only shape that can work.
  static Future<List<T>> getObjList<T>(
    String key,
    T Function(Map<String, dynamic> json) factory, {
    List<T>? defaultValue,
  }) async {
    final list = await getObjectList(key);
    if (list == null) return defaultValue ?? <T>[];
    return list.map(factory).toList();
  }

  static Future<List<Map<String, dynamic>>?> getObjectList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key);
    if (values == null) return null;
    return values
        .map((value) => EyepetizerFlutterJson.asMap(jsonDecode(value)))
        .toList();
  }
}
