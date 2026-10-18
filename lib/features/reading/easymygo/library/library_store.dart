import 'dart:convert';

import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';
import 'package:dashboard/features/reading/easymygo/library/shelf_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local shelf + history store.
///
/// EasyMyGo kept this in two drift tables (`MangaInfo`, `NovelInfo`) queried
/// through `MangaDao`/`NovelDao`:
/// * `watchStar()`  → `where(starTime > 0)`   — the shelf
/// * `watchHistory()` → `where(lastHistoryTime > 0)` — the history list
/// * `watchAll()`   → everything the reader has touched
///
/// The host has `sqflite` but the surrounding reading features (`u17_library_store`,
/// `anime_watch_store`) all use `shared_preferences` with one JSON blob, so the
/// port keeps that convention: one map keyed by `identify` under a single key.
class LibraryStore {
  LibraryStore({SharedPreferences? preferences}) : _preferences = preferences;

  static const String storageKey = 'content.easymygo.library.v1';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<void> _pending = Future<void>.value();

  Future<T> _serialize<T>(Future<T> Function() action) {
    final completer = _pending.then((_) => action());
    _pending = completer.then<void>((_) {}, onError: (_) {});
    return completer;
  }

  Future<Map<String, ShelfItem>> readAll() async {
    final prefs = await _prefs();
    return decode(prefs.getString(storageKey));
  }

  /// Decodes the persisted map, skipping malformed rows.
  static Map<String, ShelfItem> decode(String? raw) {
    if (raw == null || raw.isEmpty) return <String, ShelfItem>{};
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return <String, ShelfItem>{};
    }
    if (decoded is! Map) return <String, ShelfItem>{};
    final result = <String, ShelfItem>{};
    decoded.forEach((key, value) {
      if (value is! Map) return;
      final item = ShelfItem.fromJson(<String, Object?>{
        for (final entry in value.entries) '${entry.key}': entry.value,
      });
      result['$key'] = item;
    });
    return result;
  }

  static String encode(Map<String, ShelfItem> items) => jsonEncode(
    <String, Object?>{for (final entry in items.entries) entry.key: entry.value.toJson()},
  );

  /// Everything the library knows about, newest first.
  Future<List<ShelfItem>> all() async {
    final items = (await readAll()).values.toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  /// `watchStar()`: pinned first, then manual order, then recency.
  Future<List<ShelfItem>> shelf() async {
    final items = (await readAll()).values
        .where((item) => item.starred || item.pinned)
        .toList();
    items.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      final byOrder = a.order.compareTo(b.order);
      if (byOrder != 0) return byOrder;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return items;
  }

  /// `watchHistory()`: only books with reading progress, newest first.
  Future<List<ShelfItem>> history() async {
    final items = (await readAll()).values
        .where((item) => item.hasHistory)
        .toList();
    items.sort((a, b) {
      final left = a.progress?.updatedAt ?? a.updatedAt;
      final right = b.progress?.updatedAt ?? b.updatedAt;
      return right.compareTo(left);
    });
    return items;
  }

  Future<ShelfItem?> itemOf(String identify) async =>
      (await readAll())[identify];

  Future<ReadingProgress?> progressOf(String identify) async =>
      (await readAll())[identify]?.progress;

  /// Adds or refreshes a book without touching its reading history.
  Future<ShelfItem> remember(BookCover cover, {int? now}) => _serialize(() async {
    final items = await readAll();
    final existing = items[cover.identify];
    final next = (existing ?? ShelfItem(cover: cover)).copyWith(
      cover: cover,
      updatedAt: now ?? DateTime.now().millisecondsSinceEpoch,
    );
    items[cover.identify] = next;
    final prefs = await _prefs();
    await prefs.setString(storageKey, encode(items));
    return next;
  });

  /// Writes reading progress and marks the book as read-to (`last_history_time`).
  Future<ShelfItem> saveProgress(
    BookCover cover,
    ReadingProgress progress,
  ) => _serialize(() async {
    final items = await readAll();
    final existing = items[cover.identify] ?? ShelfItem(cover: cover);
    final next = existing.copyWith(
      cover: cover,
      progress: progress,
      updatedAt: progress.updatedAt,
    );
    items[cover.identify] = next;
    final prefs = await _prefs();
    await prefs.setString(storageKey, encode(items));
    return next;
  });

  Future<ShelfItem?> setStarred(BookCover cover, bool starred) =>
      _update(cover, (item) => item.copyWith(starred: starred));

  Future<ShelfItem?> setPinned(BookCover cover, bool pinned) =>
      _update(cover, (item) => item.copyWith(pinned: pinned));

  Future<ShelfItem?> setOrder(BookCover cover, int order) =>
      _update(cover, (item) => item.copyWith(order: order));

  Future<void> remove(String identify) => _serialize(() async {
    final items = await readAll();
    if (items.remove(identify) == null) return;
    final prefs = await _prefs();
    await prefs.setString(storageKey, encode(items));
  });

  Future<void> clear() => _serialize(() async {
    final prefs = await _prefs();
    await prefs.remove(storageKey);
  });

  Future<ShelfItem?> _update(
    BookCover cover,
    ShelfItem Function(ShelfItem item) transform,
  ) => _serialize(() async {
    final items = await readAll();
    final existing = items[cover.identify] ?? ShelfItem(cover: cover);
    final next = transform(existing).copyWith(
      cover: cover,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    items[cover.identify] = next;
    final prefs = await _prefs();
    await prefs.setString(storageKey, encode(items));
    return next;
  });
}
