import 'dart:convert';

import 'package:dashboard/features/anime/animeone/animeone_watch_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 观看记录的本地持久化（SharedPreferences + JSON），最多保留 100 条。
class AnimeOneWatchStore {
  AnimeOneWatchStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String storageKey = 'AnimeOneWatchHistory';
  static const int maxEntries = 100;

  /// 超过这个时长即视为看完（单集一般 24 分钟）。
  static const int doneThresholdSec = 20 * 60;

  final SharedPreferences? _preferences;
  SharedPreferences? _resolved;
  List<AnimeOneWatchEntry> _entries = [];
  bool _loaded = false;

  /// 按最近观看时间倒序。
  List<AnimeOneWatchEntry> get entries => List.unmodifiable(_entries);

  bool get isLoaded => _loaded;

  Future<SharedPreferences> _prefs() async =>
      _resolved ??= _preferences ?? await SharedPreferences.getInstance();

  /// 从本地载入记录，重复调用只读一次。
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await _prefs();
    final raw = prefs.getString(storageKey);
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw);
      if (data is List) {
        _entries = data
            .whereType<Map<String, dynamic>>()
            .map(AnimeOneWatchEntry.fromJson)
            .toList();
      }
    }
    _sort();
    _loaded = true;
  }

  void _sort() => _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// 新增或覆盖一条记录，并把它排到最前。
  Future<void> save(AnimeOneWatchEntry entry) async {
    await load();
    final link = AnimeOneWatchEntry.absoluteLink(entry.episodeLink);
    _entries.removeWhere(
      (item) => AnimeOneWatchEntry.absoluteLink(item.episodeLink) == link,
    );
    _entries.insert(0, entry);
    if (_entries.length > maxEntries) {
      _entries = _entries.sublist(0, maxEntries);
    }
    await _persist();
  }

  /// 按链接查找记录，自动补全相对链接。
  AnimeOneWatchEntry? entryFor(String link) {
    final target = AnimeOneWatchEntry.absoluteLink(link);
    for (final entry in _entries) {
      if (AnimeOneWatchEntry.absoluteLink(entry.episodeLink) == target) {
        return entry;
      }
    }
    return null;
  }

  /// 更新播放进度，播放超过阈值直接标记看完。
  Future<void> updatePosition(String link, int positionSec) async {
    await load();
    final entry = entryFor(link);
    if (entry == null) return;
    entry.positionSec = positionSec;
    if (entry.durationSec == 0 && positionSec >= doneThresholdSec) {
      entry.done = true;
    } else if (entry.durationSec > 0) {
      entry.done = positionSec >= entry.durationSec * 0.88;
    }
    await _persist();
  }

  /// 清空全部记录。
  Future<void> clear() async {
    await load();
    _entries = [];
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await _prefs();
    final payload = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(storageKey, payload);
  }
}
