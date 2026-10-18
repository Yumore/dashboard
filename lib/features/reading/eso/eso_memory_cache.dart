import 'dart:async';
import 'dart:collection';

/// 按容量逐出的小缓存（逐字移植 eso `lib/utils/memory_cache.dart`）。
class EsoMemoryCache<K, V> {
  EsoMemoryCache({this.cacheSize = 20});

  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final int cacheSize;

  void setValue(K key, V value) {
    if (!_cache.containsKey(key)) {
      _cache[key] = value;
      // 没必要每次都清理
      if (_cache.length > cacheSize + 4) {
        while (_cache.length > cacheSize) {
          final k = _cache.keys.first;
          _cache.remove(k);
        }
      }
    }
  }

  V? getValue(K key) => _cache[key];

  Future<V> getValueOrSet(K key, FutureOr<V> Function() or) async {
    final cached = _cache[key];
    if (cached != null) return cached;
    final value = await or();
    setValue(key, value);
    return value;
  }

  bool containsKey(K key) => _cache.containsKey(key);

  int get size => _cache.length;

  void clear() => _cache.clear();
}
