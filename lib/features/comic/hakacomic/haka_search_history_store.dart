import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Search-term history: most-recent-first, de-duplicated, capped at
/// [maxEntries].
///
/// Mirrors the upstream `AppConf.searchHistory` rules
/// (`haka_comic/lib/config/app_config.dart` and
/// `haka_comic/lib/providers/search_provider.dart`), persisted under a
/// feature-private key instead of the app-wide config blob.
class HakaSearchHistoryStore {
  HakaSearchHistoryStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'hakacomic_search_history';

  /// Upstream kept at most 20 terms.
  static const int maxEntries = 20;

  List<String> read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    return (jsonDecode(raw) as List<dynamic>).map((item) => '$item').toList();
  }

  /// Moves [term] to the front, dropping duplicates and the overflow.
  Future<List<String>> add(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return read();
    final next = [trimmed, ...read().where((item) => item != trimmed)];
    final capped = next.length > maxEntries
        ? next.sublist(0, maxEntries)
        : next;
    await _prefs.setString(storageKey, jsonEncode(capped));
    return capped;
  }

  Future<void> remove(String term) async {
    final next = read().where((item) => item != term).toList();
    await _prefs.setString(storageKey, jsonEncode(next));
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
