import 'dart:io';

import 'package:dashboard/features/movie/bilivideo_down/bili_download_task.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_task_status.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_file_paths.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Table name, mirroring the host's `lib/sql/comic_down.dart` convention of
/// module-scoped name constants next to the store that owns them.
const String biliTaskTableName = 'bili_download_task';

/// Idempotent DDL. Kept public so a host `onCreate` could create the table too,
/// but the store also runs it on every open, which is why no host file has to be
/// modified for this module to work.
const String biliTaskCreateTableSql =
    'CREATE TABLE IF NOT EXISTS $biliTaskTableName ('
    'bvid TEXT NOT NULL PRIMARY KEY, '
    'aid INTEGER NOT NULL DEFAULT 0, '
    'cid INTEGER NOT NULL DEFAULT 0, '
    'title TEXT NOT NULL DEFAULT \'\', '
    'episode_title TEXT NOT NULL DEFAULT \'\', '
    'cover TEXT NOT NULL DEFAULT \'\', '
    'quality INTEGER NOT NULL DEFAULT 0, '
    'format TEXT NOT NULL DEFAULT \'flv\', '
    'status TEXT NOT NULL DEFAULT \'pending\', '
    'received_bytes INTEGER NOT NULL DEFAULT 0, '
    'total_bytes INTEGER NOT NULL DEFAULT 0, '
    'file_path TEXT NOT NULL DEFAULT \'\', '
    'error_message TEXT NOT NULL DEFAULT \'\', '
    'created_at INTEGER NOT NULL DEFAULT 0, '
    'updated_at INTEGER NOT NULL DEFAULT 0'
    ')';

/// Persistence for download tasks, keyed by `bvid` like the source app's
/// `video_info` table.
///
/// Ports `lib/storage/dao/video_info_dao.dart` (`rawInsert`, `queryAll`,
/// `updateDownloadStatus`, `existByBvid`, `deleteByBvid`, `clear`) onto its own
/// sqflite file: the source shipped a prebuilt `assets/flutter.db` that it
/// copied out of the bundle, which is not possible here, so the table is created
/// on open instead.
///
/// The [Database] is injectable in two ways so the store is testable without
/// platform channels: [BiliTaskStore.forDatabase] wraps a caller-owned handle,
/// and the default constructor's `opener` can be replaced with any
/// `Future<Database> Function()`.
class BiliTaskStore {
  BiliTaskStore({
    Future<Database> Function()? opener,
    this.fileName = defaultFileName,
  }) : _opener = opener;

  /// Wraps an already-open database (used by tests and by a host that manages
  /// its own connection). The store will not close a database it does not own.
  BiliTaskStore.forDatabase(
    Database database, {
    this.fileName = defaultFileName,
  }) : _opener = null,
       _database = database;

  /// File name of the module's own sqflite database.
  static const String defaultFileName = 'bili_video_down.db';

  final String fileName;
  final Future<Database> Function()? _opener;
  Database? _database;

  /// Whether [close] should actually close the handle.
  bool get ownsDatabase => _opener != null;

  /// Resolves the open database, creating the table on first use.
  Future<Database> database() async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;
    final handle = await (_opener ?? _openDefault)();
    _database = handle;
    await createTable(handle);
    return handle;
  }

  /// Default location: `<app documents>/databases/bili_video_down.db`, the same
  /// layout the source's `DbOpenHelper` used.
  Future<Database> _openDefault() async {
    final documents = await getApplicationDocumentsDirectory();
    final path = BiliFilePaths.joinAll(documents.path, 'databases', fileName);
    final directory = Directory(BiliFilePaths.dirname(path));
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => createTable(db),
    );
  }

  /// Creates the task table when it is missing; safe to call repeatedly.
  static Future<void> createTable(Database db) async {
    await db.execute(biliTaskCreateTableSql);
  }

  /// Inserts or replaces [task]. `bvid` is the primary key, so re-resolving the
  /// same video updates its row instead of duplicating it.
  Future<int> upsert(BiliDownloadTask task) async {
    final db = await database();
    return db.insert(
      biliTaskTableName,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Every task, newest first.
  Future<List<BiliDownloadTask>> queryAll() =>
      _query(orderBy: 'created_at DESC, bvid ASC');

  /// Completed tasks, newest first — the source's
  /// `DownloadCompleteController.refreshVideoList`.
  Future<List<BiliDownloadTask>> queryCompleted() => _query(
    where: 'status = ?',
    whereArgs: <Object?>[BiliTaskStatus.completed.name],
    orderBy: 'created_at DESC, bvid ASC',
  );

  /// Tasks the UI can offer to resume after a restart.
  Future<List<BiliDownloadTask>> queryResumable() => _query(
    where: 'status IN (?, ?, ?, ?)',
    whereArgs: <Object?>[
      BiliTaskStatus.pending.name,
      BiliTaskStatus.downloading.name,
      BiliTaskStatus.paused.name,
      BiliTaskStatus.failed.name,
    ],
    orderBy: 'created_at DESC, bvid ASC',
  );

  /// `null` when no task is stored for [bvid].
  Future<BiliDownloadTask?> queryByBvid(String bvid) async {
    final rows = await _query(
      where: 'bvid = ?',
      whereArgs: <Object?>[bvid],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// The source's `existByBvid`.
  Future<bool> exists(String bvid) async => (await queryByBvid(bvid)) != null;

  Future<int> count() async {
    final db = await database();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $biliTaskTableName',
    );
    final total = rows.isEmpty ? null : rows.first['total'];
    return total is int ? total : int.tryParse('$total') ?? 0;
  }

  /// Persists byte progress (and usually the `downloading` status) for [bvid].
  Future<int> updateProgress({
    required String bvid,
    required int receivedBytes,
    required int totalBytes,
    required BiliTaskStatus status,
    required DateTime updatedAt,
  }) => _update(<String, Object?>{
    'received_bytes': receivedBytes,
    'total_bytes': totalBytes,
    'status': status.name,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  }, bvid);

  /// The source's `updateDownloadStatus`, widened with file path and error.
  Future<int> updateStatus({
    required String bvid,
    required BiliTaskStatus status,
    required DateTime updatedAt,
    String? filePath,
    String? errorMessage,
    int? receivedBytes,
    int? totalBytes,
  }) => _update(<String, Object?>{
    'status': status.name,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'file_path': ?filePath,
    'error_message': ?errorMessage,
    'received_bytes': ?receivedBytes,
    'total_bytes': ?totalBytes,
  }, bvid);

  /// Marks [bvid] finished, recording where the file landed.
  Future<int> markCompleted({
    required String bvid,
    required String filePath,
    required int totalBytes,
    required DateTime updatedAt,
  }) => _update(<String, Object?>{
    'status': BiliTaskStatus.completed.name,
    'file_path': filePath,
    'received_bytes': totalBytes,
    'total_bytes': totalBytes,
    'error_message': '',
    'updated_at': updatedAt.millisecondsSinceEpoch,
  }, bvid);

  /// The source's `deleteByBvid`.
  Future<int> deleteByBvid(String bvid) async {
    final db = await database();
    return db.delete(
      biliTaskTableName,
      where: 'bvid = ?',
      whereArgs: <Object?>[bvid],
    );
  }

  /// The source's `clear`; returns the number of removed rows.
  Future<int> clear() async {
    final db = await database();
    return db.delete(biliTaskTableName);
  }

  /// Closes the handle, but only when this store opened it.
  Future<void> close() async {
    final existing = _database;
    if (existing != null && ownsDatabase && existing.isOpen) {
      await existing.close();
    }
    if (ownsDatabase) _database = null;
  }

  Future<List<BiliDownloadTask>> _query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database();
    final rows = await db.query(
      biliTaskTableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return <BiliDownloadTask>[
      for (final row in rows) BiliDownloadTask.fromMap(row),
    ];
  }

  Future<int> _update(Map<String, Object?> values, String bvid) async {
    final db = await database();
    return db.update(
      biliTaskTableName,
      values,
      where: 'bvid = ?',
      whereArgs: <Object?>[bvid],
    );
  }
}
