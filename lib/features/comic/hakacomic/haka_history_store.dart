import 'dart:convert';

import 'package:dashboard/features/comic/hakacomic/haka_history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local read history backed by `shared_preferences`.
///
/// Deliberate deviation: upstream used sqflite
/// (`haka_comic/lib/database/history_helper.dart`); this port keeps the same
/// observable semantics (most-recent-first, de-duplicated by comic id, paged in
/// windows of [pageSize]) over a JSON list, so it needs no schema migration.
class HakaHistoryStore {
  HakaHistoryStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'hakacomic_history';

  /// Upstream hard-coded the history page window
  /// (`history_helper.dart:150-160`).
  static const int pageSize = 20;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  List<HakaHistoryEntry> _read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => HakaHistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(List<HakaHistoryEntry> entries) {
    return _prefs.setString(
      storageKey,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  /// Inserts at the front, replacing any previous row for the same comic.
  Future<void> insert(String comicId, Map<String, dynamic> doc) async {
    final entries = _read()
        .where((entry) => entry.comicId != comicId)
        .toList();
    entries.insert(
      0,
      HakaHistoryEntry(comicId: comicId, doc: doc, createdAt: _now()),
    );
    await _write(entries);
  }

  /// 0-based page of [pageSize] rows, most-recent-first.
  Future<List<HakaHistoryEntry>> getPage(int page) async {
    final entries = _read();
    final start = page * pageSize;
    if (start >= entries.length) return const [];
    final end = (start + pageSize).clamp(0, entries.length);
    return entries.sublist(start, end);
  }

  Future<int> count() async => _read().length;

  /// Comic id at the top of the list, or `null` when empty.
  Future<String?> getFirstId() async {
    final entries = _read();
    return entries.isEmpty ? null : entries.first.comicId;
  }

  Future<void> delete(String comicId) async {
    await _write(
      _read().where((entry) => entry.comicId != comicId).toList(),
    );
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
