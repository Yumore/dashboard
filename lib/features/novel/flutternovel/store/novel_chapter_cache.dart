import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';

/// The chapter-content cache (the source's `NovelContentCacheManager`).
///
/// The source cached the parsed chapter payload keyed by chapter link and kept
/// it for the life of the process. The port keeps the same key and adds a
/// wall-clock TTL on top, so a chapter that has been revised upstream is
/// re-fetched after [ttl] instead of being served forever.
///
/// [ChapterCacheStore] only stores the payload; the freshness stamp lives here,
/// which keeps the storage contract identical to the source's cache manager and
/// makes expiry testable with an injected clock and no waiting.
class NovelChapterCache {
  NovelChapterCache({
    required this.store,
    this.ttl = const Duration(hours: 24),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ChapterCacheStore store;

  /// How long a cached chapter stays fresh.
  final Duration ttl;

  final DateTime Function() _now;

  /// Counters so callers (and tests) can see whether the cache helped.
  int hits = 0;
  int misses = 0;

  final Map<String, NovelChapterContent> _memo = <String, NovelChapterContent>{};
  final Map<String, DateTime> _storedAt = <String, DateTime>{};

  /// Returns the cached chapter for [link] when a non-empty payload exists and
  /// it is still within [ttl]; otherwise null. Increments [hits] / [misses].
  Future<NovelChapterContent?> get(String link) async {
    final memoized = _memo[link];
    if (memoized != null) {
      if (memoized.isEmpty || _isExpired(link)) {
        await evict(link);
        misses++;
        return null;
      }
      hits++;
      return memoized;
    }

    final cached = await store.loadChapter(link);
    if (cached == null || cached.isEmpty) {
      misses++;
      return null;
    }

    /// A payload restored from storage has no in-process stamp yet, so it is
    /// treated as fresh on first read and stamped now.
    _memo[link] = cached;
    _storedAt[link] = _now();
    hits++;
    return cached;
  }

  /// Reads the cache without applying the TTL (used to render instantly while a
  /// refresh runs in the background).
  Future<NovelChapterContent?> peek(String link) async {
    final memoized = _memo[link];
    if (memoized != null && !memoized.isEmpty) return memoized;
    return store.loadChapter(link);
  }

  Future<void> put(String link, NovelChapterContent content) async {
    _memo[link] = content;
    _storedAt[link] = _now();
    await store.saveChapter(link, content);
  }

  /// Stores [content] only when the cache has no fresh entry, and returns the
  /// content that should be shown.
  Future<NovelChapterContent> putIfAbsent(
    String link,
    NovelChapterContent content,
  ) async {
    final existing = await get(link);
    if (existing != null) return existing;
    await put(link, content);
    return content;
  }

  Future<void> evict(String link) async {
    _memo.remove(link);
    _storedAt.remove(link);
    await store.removeChapter(link);
  }

  Future<void> clear() async {
    _memo.clear();
    _storedAt.clear();
    await store.clearChapters();
  }

  /// When the in-memory entry for [link] stops being fresh, or null.
  DateTime? expiresAt(String link) {
    final stored = _storedAt[link];
    if (stored == null) return null;
    return stored.add(ttl);
  }

  bool _isExpired(String link) {
    final deadline = expiresAt(link);
    if (deadline == null) return false;
    return !_now().isBefore(deadline);
  }
}
