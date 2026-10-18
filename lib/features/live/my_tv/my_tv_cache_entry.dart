/// A cached payload plus the wall-clock instant it was written.
class MyTvCacheEntry {
  const MyTvCacheEntry({required this.content, required this.savedAt});

  final String content;
  final DateTime savedAt;
}

/// Reads the persisted cache entry, or `null` when nothing was stored.
typedef MyTvCacheRead = Future<MyTvCacheEntry?> Function();

/// Persists a cache entry.
typedef MyTvCacheWrite = Future<void> Function(MyTvCacheEntry entry);
