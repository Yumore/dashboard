import 'package:dashboard/features/live/my_tv/my_tv_cache_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Content cache with a time-to-live, driven by an injectable clock so the
/// boundary can be exercised without waiting for real time to pass.
class MyTvTtlCache {
  MyTvTtlCache({
    required this.read,
    required this.write,
    DateTime Function()? now,
    this.ttl = const Duration(hours: 24),
  }) : _now = now ?? DateTime.now;

  /// Cache backed by [SharedPreferences], keyed by [key].
  factory MyTvTtlCache.preferences({
    required String key,
    Duration ttl = const Duration(hours: 24),
    DateTime Function()? now,
  }) {
    final contentKey = '${key}_content';
    final timeKey = '${key}_time';
    return MyTvTtlCache(
      ttl: ttl,
      now: now,
      read: () async {
        final prefs = await SharedPreferences.getInstance();
        final content = prefs.getString(contentKey);
        final stamp = prefs.getInt(timeKey);
        if (content == null || stamp == null) return null;
        return MyTvCacheEntry(
          content: content,
          savedAt: DateTime.fromMillisecondsSinceEpoch(stamp),
        );
      },
      write: (entry) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(contentKey, entry.content);
        await prefs.setInt(timeKey, entry.savedAt.millisecondsSinceEpoch);
      },
    );
  }

  final MyTvCacheRead read;
  final MyTvCacheWrite write;
  final DateTime Function() _now;
  final Duration ttl;

  /// Cached content, or `null` when missing, empty, or not older than [ttl].
  ///
  /// An entry whose age is exactly [ttl] is already stale, matching the source
  /// app's `now - cacheTime < keepTime` check.
  Future<String?> get() async {
    final entry = await read();
    if (entry == null) return null;
    if (_now().difference(entry.savedAt) >= ttl) return null;
    return entry.content.isEmpty ? null : entry.content;
  }

  /// Stores [content], stamping it with the current (injected) time.
  Future<void> put(String content) =>
      write(MyTvCacheEntry(content: content, savedAt: _now()));
}
