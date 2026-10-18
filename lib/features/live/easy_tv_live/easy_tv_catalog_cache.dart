import 'package:shared_preferences/shared_preferences.dart';

/// Persists the raw playlist text so a failed refresh can still start playback,
/// porting the source app's `m3u_cache` key.
class EasyTvCatalogCache {
  const EasyTvCatalogCache({SharedPreferences? preferences})
    : _preferences = preferences;

  final SharedPreferences? _preferences;

  static const storageKey = 'easy_tv_live_m3u_cache';

  Future<SharedPreferences> _prefs() async =>
      _preferences ?? SharedPreferences.getInstance();

  Future<String?> load() async {
    final value = (await _prefs()).getString(storageKey);
    return value == null || value.trim().isEmpty ? null : value;
  }

  Future<void> save(String content) async {
    await (await _prefs()).setString(storageKey, content);
  }

  Future<void> clear() async {
    await (await _prefs()).remove(storageKey);
  }
}
