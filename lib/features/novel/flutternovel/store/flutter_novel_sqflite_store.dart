import 'dart:convert';

import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:sqflite/sqflite.dart';

/// The sqflite-backed [FlutterNovelStore].
///
/// The host's own DB (`comic_history.db`, opened in lib/main.dart) is created
/// and owned outside this feature's write scope, so the port opens its own file
/// (`flutternovel.db`) through the same `sqflite` dependency and the same
/// "constants for table/column names + a Provider with static helpers" style as
/// lib/sql/comic_history.dart.
///
/// Schema (v2):
/// ```
/// CREATE TABLE flutternovel_shelf (
///   book_id TEXT PRIMARY KEY, title TEXT, author TEXT, cover TEXT,
///   source_id TEXT, last_chapter TEXT, chapters_count INTEGER, added_at INTEGER)
/// CREATE TABLE flutternovel_progress (
///   book_id TEXT PRIMARY KEY, chapter_index INTEGER, page_index INTEGER,
///   chapter_id TEXT, chapter_title TEXT, updated_at INTEGER)
/// CREATE TABLE flutternovel_chapter_cache (
///   link TEXT PRIMARY KEY, content TEXT, updated_at INTEGER)
/// ```
class FlutterNovelSqfliteStore extends FlutterNovelStore {
  FlutterNovelSqfliteStore({this.fileName = defaultFileName});

  static const String defaultFileName = 'flutternovel.db';
  static const int schemaVersion = 2;

  static const String shelfTable = 'flutternovel_shelf';
  static const String progressTable = 'flutternovel_progress';
  static const String chapterCacheTable = 'flutternovel_chapter_cache';

  /// The database file name inside the platform's databases directory.
  final String fileName;
  Database? _database;

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError(
        'FlutterNovelSqfliteStore.open() must be awaited before use.',
      );
    }
    return db;
  }

  /// The raw `onCreate` DDL, exposed so the schema can be asserted without a
  /// platform database.
  static const List<String> createStatements = <String>[
    'CREATE TABLE $shelfTable ('
        'book_id TEXT PRIMARY KEY NOT NULL, '
        'title TEXT NOT NULL, '
        'author TEXT NOT NULL, '
        'cover TEXT NOT NULL, '
        'source_id TEXT NOT NULL, '
        'last_chapter TEXT NOT NULL, '
        'chapters_count INTEGER NOT NULL, '
        'added_at INTEGER NOT NULL)',
    'CREATE TABLE $progressTable ('
        'book_id TEXT PRIMARY KEY NOT NULL, '
        'chapter_index INTEGER NOT NULL, '
        'page_index INTEGER NOT NULL, '
        'chapter_id TEXT NOT NULL, '
        'chapter_title TEXT NOT NULL, '
        'updated_at INTEGER NOT NULL)',
    'CREATE TABLE $chapterCacheTable ('
        'link TEXT PRIMARY KEY NOT NULL, '
        'content TEXT NOT NULL, '
        'updated_at INTEGER NOT NULL)',
  ];

  @override
  Future<void> open() async {
    if (_database != null) return;
    final path = '${await getDatabasesPath()}/$fileName';
    _database = await openDatabase(
      path,
      version: schemaVersion,
      onCreate: (Database db, int version) async {
        for (final statement in createStatements) {
          await db.execute(statement);
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  @override
  Future<List<FlutterNovelShelfEntry>> loadShelf() async {
    final rows = await database.query(
      shelfTable,
      orderBy: 'added_at DESC',
    );
    return rows
        .map(FlutterNovelShelfEntry.fromMap)
        .where((entry) => entry.bookId.isNotEmpty)
        .toList();
  }

  @override
  Future<void> saveShelfEntry(FlutterNovelShelfEntry entry) async {
    await database.insert(
      shelfTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeShelfEntry(String bookId) async {
    await database.delete(
      shelfTable,
      where: 'book_id = ?',
      whereArgs: <Object?>[bookId],
    );
  }

  @override
  Future<bool> containsShelfEntry(String bookId) async {
    final rows = await database.query(
      shelfTable,
      columns: const <String>['book_id'],
      where: 'book_id = ?',
      whereArgs: <Object?>[bookId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<FlutterNovelProgress?> loadProgress(String bookId) async {
    final rows = await database.query(
      progressTable,
      where: 'book_id = ?',
      whereArgs: <Object?>[bookId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FlutterNovelProgress.fromMap(rows.first);
  }

  @override
  Future<void> saveProgress(FlutterNovelProgress progress) async {
    await database.insert(
      progressTable,
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeProgress(String bookId) async {
    await database.delete(
      progressTable,
      where: 'book_id = ?',
      whereArgs: <Object?>[bookId],
    );
  }

  @override
  Future<NovelChapterContent?> loadChapter(String link) async {
    final rows = await database.query(
      chapterCacheTable,
      columns: const <String>['content'],
      where: 'link = ?',
      whereArgs: <Object?>[link],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['content'];
    if (raw is! String || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return NovelChapterContent.fromJson(decoded.cast<String, dynamic>());
  }

  @override
  Future<void> saveChapter(String link, NovelChapterContent content) async {
    await database.insert(
      chapterCacheTable,
      <String, dynamic>{
        'link': link,
        'content': jsonEncode(content.toJson()),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeChapter(String link) async {
    await database.delete(
      chapterCacheTable,
      where: 'link = ?',
      whereArgs: <Object?>[link],
    );
  }

  @override
  Future<void> clearChapters() async {
    await database.delete(chapterCacheTable);
  }
}
