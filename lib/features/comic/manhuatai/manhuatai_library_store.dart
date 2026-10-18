import 'dart:convert';

import 'package:dashboard/features/comic/manhuatai/manhuatai_favorite.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_read_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for favourites, reading history and search history.
///
/// The source kept favourites/history in `sqflite` (`HasReadChaptersDbProvider`)
/// plus `shared_preferences` (`SP`); this port uses `shared_preferences` for all
/// three, which keeps the module dependency-free and testable with
/// `SharedPreferences.setMockInitialValues`.
///
/// Writes are chained on [_pending] so concurrent calls cannot interleave a
/// read-modify-write of the same key (same pattern as the host's U17 store).
class ManhuataiLibraryStore {
  ManhuataiLibraryStore({SharedPreferences? preferences})
      : _preferences = preferences;

  static const String favoritesKey = 'content.manhuatai.favorites.v1';
  static const String historyKey = 'content.manhuatai.history.v1';
  static const String searchHistoryKey = 'content.manhuatai.search.v1';

  /// History is capped so the list cannot grow without bound.
  static const int historyLimit = 200;
  static const int searchHistoryLimit = 20;

  SharedPreferences? _preferences;
  Future<void>? _pending;

  Future<SharedPreferences> _prefs() async {
    final existing = _preferences;
    if (existing != null) {
      return existing;
    }
    final loaded = await SharedPreferences.getInstance();
    _preferences = loaded;
    return loaded;
  }

  Future<T> _serialise<T>(Future<T> Function() action) {
    final previous = _pending ?? Future<void>.value();
    final result = previous.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  List<Map<String, dynamic>> _decodeList(String raw) {
    if (raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
          .toList();
    } on FormatException {
      return <Map<String, dynamic>>[];
    }
  }

  // ------------------------------------------------------------- favourites

  Future<List<ManhuataiFavorite>> favorites() async {
    final prefs = await _prefs();
    final raw = prefs.getString(favoritesKey) ?? '';
    return _decodeList(raw).map(ManhuataiFavorite.fromJson).toList();
  }

  Future<bool> isFavorite(int comicId) async {
    final items = await favorites();
    return items.any((item) => item.comicId == comicId);
  }

  /// Adds or removes [favorite]; returns the resulting membership state.
  Future<bool> toggleFavorite(ManhuataiFavorite favorite) {
    return _serialise(() async {
      final prefs = await _prefs();
      final items = await favorites();
      final exists = items.any((item) => item.comicId == favorite.comicId);
      final next = exists
          ? items.where((item) => item.comicId != favorite.comicId).toList()
          : <ManhuataiFavorite>[favorite, ...items];
      await prefs.setString(
        favoritesKey,
        jsonEncode(next.map((item) => item.toJson()).toList()),
      );
      return !exists;
    });
  }

  // ---------------------------------------------------------------- history

  Future<List<ManhuataiReadRecord>> history() async {
    final prefs = await _prefs();
    final raw = prefs.getString(historyKey) ?? '';
    return _decodeList(raw).map(ManhuataiReadRecord.fromJson).toList();
  }

  /// Inserts or moves [record] to the front, one entry per comic.
  Future<void> remember(ManhuataiReadRecord record) {
    return _serialise(() async {
      final prefs = await _prefs();
      final items = await history();
      final next = <ManhuataiReadRecord>[
        record,
        ...items.where((item) => item.comicId != record.comicId),
      ];
      final trimmed = next.length > historyLimit
          ? next.sublist(0, historyLimit)
          : next;
      await prefs.setString(
        historyKey,
        jsonEncode(trimmed.map((item) => item.toJson()).toList()),
      );
    });
  }

  Future<void> removeHistory(int comicId) {
    return _serialise(() async {
      final prefs = await _prefs();
      final items = await history();
      final next =
          items.where((item) => item.comicId != comicId).toList();
      await prefs.setString(
        historyKey,
        jsonEncode(next.map((item) => item.toJson()).toList()),
      );
    });
  }

  Future<void> clearHistory() {
    return _serialise(() async {
      final prefs = await _prefs();
      await prefs.remove(historyKey);
    });
  }

  // --------------------------------------------------------- search history

  Future<List<String>> searchHistory() async {
    final prefs = await _prefs();
    return prefs.getStringList(searchHistoryKey) ?? <String>[];
  }

  /// Adds [keyword] to the front, de-duplicated and capped.
  Future<void> rememberSearch(String keyword) {
    return _serialise(() async {
      final prefs = await _prefs();
      final items = await searchHistory();
      final next = <String>[
        keyword,
        ...items.where((item) => item != keyword),
      ];
      final trimmed = next.length > searchHistoryLimit
          ? next.sublist(0, searchHistoryLimit)
          : next;
      await prefs.setStringList(searchHistoryKey, trimmed);
    });
  }

  Future<void> clearSearchHistory() {
    return _serialise(() async {
      final prefs = await _prefs();
      await prefs.remove(searchHistoryKey);
    });
  }
}
