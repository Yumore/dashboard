import 'dart:convert';

import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dashboard/features/comic/u17_reading_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapts comic_flutter's per-comic favorites and last-read chapter storage.
class U17LibraryStore {
  static const _favoritesKey = 'content.u17.favorites.v1';
  static const _historyKey = 'content.u17.history.v1';
  Future<void> _pending = Future.value();

  Future<List<U17Comic>> favorites() async {
    final rows = await _read(_favoritesKey);
    return rows.map(U17Comic.fromJson).where((comic) => comic.id > 0).toList();
  }

  Future<List<U17ReadingRecord>> history() async {
    final rows = await _read(_historyKey);
    return rows.map(U17ReadingRecord.fromJson).toList()
      ..sort((a, b) => b.readAt.compareTo(a.readAt));
  }

  Future<void> setFavorite(U17Comic comic, bool favorite) =>
      _serialize(() async {
        final items = await favorites();
        items.removeWhere((item) => item.id == comic.id);
        if (favorite) items.insert(0, comic);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _favoritesKey,
          items.map((item) => jsonEncode(item.toJson())).toList(),
        );
      });

  Future<void> remember(U17Comic comic, U17Chapter chapter) =>
      _serialize(() async {
        final items = await history();
        items.removeWhere((item) => item.comic.id == comic.id);
        items.insert(
          0,
          U17ReadingRecord(
            comic: comic,
            chapter: chapter,
            readAt: DateTime.now(),
          ),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _historyKey,
          items.map((item) => jsonEncode(item.toJson())).toList(),
        );
      });

  Future<List<Map<String, dynamic>>> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(key) ?? [])
        .map((row) => Map<String, dynamic>.from(jsonDecode(row) as Map))
        .toList();
  }

  Future<void> _serialize(Future<void> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.catchError((Object _) {});
    return result;
  }
}
