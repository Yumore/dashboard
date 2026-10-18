/// Process-local response cache.
///
/// Upstream used it only for the hot-search-words payload
/// (`haka_comic/lib/network/http.dart:372-386`).
class HakaCache {
  HakaCache();

  static final HakaCache instance = HakaCache();

  final Map<String, Map<String, dynamic>> _store = {};

  Map<String, dynamic>? get(String key) => _store[key];

  void add(String key, Map<String, dynamic> value) {
    _store[key] = value;
  }

  bool contains(String key) => _store.containsKey(key);

  void clear() => _store.clear();
}
