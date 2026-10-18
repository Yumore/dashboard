import 'dart:convert';

import 'package:dashboard/features/comic/picacomic/core/comic_source_data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists comic-source data as a JSON string in `shared_preferences`.
///
/// Replaces PicaComic's `${dataPath}/comic_source/<key>.data` files.
class SharedPreferencesComicSourceStore implements ComicSourceDataStore {
  const SharedPreferencesComicSourceStore();

  static const String keyPrefix = 'content.picacomic.source.';

  static String preferenceKey(String sourceKey) => '$keyPrefix$sourceKey';

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(preferenceKey(key));
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  @override
  Future<void> write(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(preferenceKey(key), jsonEncode(data));
  }
}
