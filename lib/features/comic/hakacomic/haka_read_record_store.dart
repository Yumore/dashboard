import 'dart:convert';

import 'package:dashboard/features/comic/hakacomic/haka_read_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Last-read position per comic, backed by `shared_preferences`.
///
/// Deliberate deviation: upstream used sqflite
/// (`haka_comic/lib/database/read_record_helper.dart`); the observable
/// behaviour (one record per comic, upsert, delete, clear) is preserved.
class HakaReadRecordStore {
  HakaReadRecordStore(this._prefs);

  final SharedPreferences _prefs;

  static const String storageKey = 'hakacomic_read_records';

  Map<String, dynamic> _readAll() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return {};
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<void> _writeAll(Map<String, dynamic> all) {
    return _prefs.setString(storageKey, jsonEncode(all));
  }

  Future<HakaReadRecord?> get(String comicId) async {
    final value = _readAll()[comicId];
    if (value is! Map) return null;
    return HakaReadRecord.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> save(HakaReadRecord record) async {
    final all = _readAll();
    all[record.comicId] = record.toJson();
    await _writeAll(all);
  }

  /// Convenience for the reader: keeps the existing chapter/title and only
  /// advances the page.
  Future<HakaReadRecord> savePage(String comicId, int pageNo) async {
    final existing =
        await get(comicId) ??
        HakaReadRecord(
          comicId: comicId,
          chapterId: '',
          chapterOrder: 1,
          chapterTitle: '',
          pageNo: 1,
        );
    final updated = existing.copyWith(pageNo: pageNo);
    await save(updated);
    return updated;
  }

  Future<void> markFinished(String comicId) async {
    final existing = await get(comicId);
    if (existing == null) return;
    await save(existing.copyWith(finished: true));
  }

  Future<void> remove(String comicId) async {
    final all = _readAll();
    if (all.remove(comicId) == null) return;
    await _writeAll(all);
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
