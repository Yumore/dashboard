import 'dart:convert';

import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ports PicaComic lib/foundation/history.dart's `History` row.
///
/// The source stored these rows in sqlite3 (`history` table); the host has no
/// sqlite3 package, so [HistoryManager] persists the very same rows as JSON in
/// shared_preferences. The serialized keys stay identical to the source's
/// column names.
class History {
  History({
    required this.type,
    required this.time,
    required this.title,
    this.subtitle,
    required this.cover,
    this.ep = 0,
    this.page = 0,
    required this.target,
    Set<int>? readEpisode,
    this.maxPage,
  }) : readEpisode = readEpisode ?? <int>{};

  /// `History.fromComic` (history.dart:100-120).
  factory History.fromComic(
    HistoryMixin comic, {
    int ep = 0,
    int page = 0,
    DateTime? now,
  }) => History(
    type: comic.historyType,
    time: (now ?? DateTime.now()).millisecondsSinceEpoch,
    title: comic.title,
    subtitle: comic.subTitle,
    cover: comic.cover,
    ep: ep,
    page: page,
    target: comic.target,
    maxPage: comic.maxPage,
  );

  factory History.fromMap(Map<dynamic, dynamic> map) => History(
    type: HistoryType.fromKey(map['type'] as int? ?? 0),
    time: map['time'] as int? ?? 0,
    title: '${map['title'] ?? ''}',
    subtitle: map['subtitle'] == null ? null : '${map['subtitle']}',
    cover: '${map['cover'] ?? ''}',
    ep: map['ep'] as int? ?? 0,
    page: map['page'] as int? ?? 0,
    target: '${map['target'] ?? ''}',
    readEpisode: ((map['readEpisode'] as List?) ?? const [])
        .map((value) => value is int ? value : int.tryParse('$value') ?? 0)
        .toSet(),
    maxPage: map['max_page'] as int?,
  );

  HistoryType type;
  int time;
  String title;
  String? subtitle;
  String cover;
  int ep;
  int page;
  String target;

  /// Read chapter indices, kept as a set exactly like the source column.
  Set<int> readEpisode;
  int? maxPage;

  Map<String, dynamic> toMap() => {
    'type': type.value,
    'time': time,
    'title': title,
    'subtitle': subtitle,
    'cover': cover,
    'ep': ep,
    'page': page,
    'target': target,
    'readEpisode': readEpisode.toList(),
    'max_page': maxPage,
  };

  DateTime get readAt => DateTime.fromMillisecondsSinceEpoch(time);

  @override
  String toString() => 'History($target, ep=$ep, page=$page)';
}

/// Ports the `HistoryManager` singleton of lib/foundation/history.dart.
///
/// Persistence deviation: shared_preferences instead of sqlite3. Behaviour is
/// kept: newest-first ordering by `time`, `addHistory` only bumps `time` for an
/// existing target, `saveReadHistory` updates ep/page/readEpisode/max_page.
class HistoryManager {
  HistoryManager({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  /// The source used a bare `HistoryManager()` singleton.
  static final HistoryManager instance = HistoryManager();

  static const String storeKey = 'content.picacomic.history.v1';

  final DateTime Function() _clock;
  Future<void> _pending = Future.value();
  List<History>? _cache;

  Future<void> init() async {
    _cache = await _read();
  }

  /// Synchronous lookup over the last loaded snapshot (source: `findSync`).
  History? findSync(String target) {
    for (final history in _cache ?? const <History>[]) {
      if (history.target == target) return history;
    }
    return null;
  }

  Future<History?> find(String target) async {
    for (final history in await getAll()) {
      if (history.target == target) return history;
    }
    return null;
  }

  Future<List<History>> getAll() async {
    final items = [...await _read()]
      ..sort((a, b) => b.time.compareTo(a.time));
    _cache = items;
    return items;
  }

  Future<List<History>> getRecent({int limit = 20}) async =>
      (await getAll()).take(limit).toList();

  Future<int> count() async => (await _read()).length;

  /// Inserts a new row, or only refreshes `time` when the target exists
  /// (history.dart:150-175).
  Future<History> addHistory(History history) => _serialize(() async {
    final items = await _read();
    final index = items.indexWhere((item) => item.target == history.target);
    if (index >= 0) {
      items[index].time = _clock().millisecondsSinceEpoch;
      await _write(items);
      return items[index];
    }
    items.add(history);
    await _write(items);
    return history;
  });

  /// `findOrCreate` (history.dart:178-195).
  Future<History> findOrCreate(History history) async =>
      await find(history.target) ?? await addHistory(history);

  /// `saveReadHistory` (history.dart:198-230): always bumps `time`, and updates
  /// the reading position when [updatePage] is true.
  Future<void> saveReadHistory(
    History history, {
    bool updatePage = true,
  }) => _serialize(() async {
    final items = await _read();
    final index = items.indexWhere((item) => item.target == history.target);
    if (index < 0) {
      items.add(history);
    } else {
      final stored = items[index];
      stored.time = _clock().millisecondsSinceEpoch;
      stored.ep = history.ep;
      if (updatePage) {
        stored.page = history.page;
      }
      stored.readEpisode = history.readEpisode;
      if (history.maxPage != null) {
        stored.maxPage = history.maxPage;
      }
    }
    await _write(items);
  });

  Future<void> remove(String target) => _serialize(() async {
    final items = await _read()
      ..removeWhere((item) => item.target == target);
    await _write(items);
  });

  Future<void> clear() => _serialize(() => _write([]));

  Future<List<History>> _read() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(storeKey) ?? const <String>[])
        .map((row) => History.fromMap(jsonDecode(row) as Map))
        .toList();
  }

  Future<void> _write(List<History> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      storeKey,
      items.map((item) => jsonEncode(item.toMap())).toList(),
    );
    _cache = items;
  }

  Future<T> _serialize<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then((_) {}, onError: (Object _) {});
    return result;
  }
}
