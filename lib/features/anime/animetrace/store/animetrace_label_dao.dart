import 'package:dashboard/features/anime/animetrace/animetrace_label.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';

/// `label` plus the `anime_label` join table: user labels and the label
/// membership of each collected anime.
class AnimeTraceLabelDao {
  AnimeTraceLabelDao(this._db);

  final AnimeTraceExecutor _db;

  static const String _table = AnimeTraceSchema.labelTable;
  static const String _joinTable = AnimeTraceSchema.animeLabelTable;

  Future<int> insert(String name) {
    return _db.rawInsert('insert into $_table (name) values (?)', <Object?>[
      name,
    ]);
  }

  Future<int> update(int id, String newName) {
    return _db.rawUpdate('update $_table set name = ? where id = ?', <Object?>[
      newName,
      id,
    ]);
  }

  /// Deletes a label and every membership row pointing at it.
  Future<void> delete(int id) async {
    final database = _db;
    Future<void> run(AnimeTraceExecutor executor) async {
      await executor.rawDelete(
        'delete from $_joinTable where label_id = ?',
        <Object?>[id],
      );
      await executor.rawDelete('delete from $_table where id = ?', <Object?>[
        id,
      ]);
    }

    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction(run);
    } else {
      await run(database);
    }
  }

  Future<List<AnimeTraceLabel>> getAll() async {
    final rows = await _db.rawQuery('select id, name from $_table order by id');
    return rows.map(AnimeTraceLabel.fromMap).toList();
  }

  Future<AnimeTraceLabel> getById(int id) async {
    final rows = await _db.rawQuery(
      'select id, name from $_table where id = ? limit 1',
      <Object?>[id],
    );
    if (rows.isEmpty) return AnimeTraceLabel.none();
    return AnimeTraceLabel.fromMap(rows.first);
  }

  Future<List<AnimeTraceLabel>> search(String keyword) async {
    final rows = await _db.rawQuery(
      'select id, name from $_table where name like ? order by id',
      <Object?>['%$keyword%'],
    );
    return rows.map(AnimeTraceLabel.fromMap).toList();
  }

  Future<bool> existName(String name) async {
    final rows = await _db.rawQuery(
      'select id from $_table where name = ? limit 1',
      <Object?>[name],
    );
    return rows.isNotEmpty;
  }

  Future<List<int>> getAnimeIdsByLabelId(int labelId) async {
    final rows = await _db.rawQuery(
      'select anime_id from $_joinTable where label_id = ? order by anime_id',
      <Object?>[labelId],
    );
    return rows.map((row) => _asInt(row['anime_id'])).toList();
  }

  Future<List<int>> getLabelIdsByAnimeId(int animeId) async {
    final rows = await _db.rawQuery(
      'select label_id from $_joinTable where anime_id = ? order by label_id',
      <Object?>[animeId],
    );
    return rows.map((row) => _asInt(row['label_id'])).toList();
  }

  Future<List<AnimeTraceLabel>> getLabelsByAnimeId(int animeId) async {
    final rows = await _db.rawQuery(
      'select label.id, label.name from label inner join $_joinTable '
      'on label.id = $_joinTable.label_id where $_joinTable.anime_id = ? '
      'order by label.id',
      <Object?>[animeId],
    );
    return rows.map(AnimeTraceLabel.fromMap).toList();
  }

  Future<int> addAnimeLabel(int animeId, int labelId) {
    return _db.rawInsert(
      'insert into $_joinTable (anime_id, label_id) values (?, ?)',
      <Object?>[animeId, labelId],
    );
  }

  Future<int> deleteAnimeLabel(int animeId, int labelId) {
    return _db.rawDelete(
      'delete from $_joinTable where anime_id = ? and label_id = ?',
      <Object?>[animeId, labelId],
    );
  }

  Future<int> deleteByAnimeId(int animeId) {
    return _db.rawDelete(
      'delete from $_joinTable where anime_id = ?',
      <Object?>[animeId],
    );
  }

  /// Replaces the anime's label set with [labelIds].
  Future<void> setAnimeLabels(int animeId, List<int> labelIds) async {
    final database = _db;
    Future<void> run(AnimeTraceExecutor executor) async {
      await executor.rawDelete(
        'delete from $_joinTable where anime_id = ?',
        <Object?>[animeId],
      );
      for (final labelId in labelIds) {
        await executor.rawInsert(
          'insert into $_joinTable (anime_id, label_id) values (?, ?)',
          <Object?>[animeId, labelId],
        );
      }
    }

    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction(run);
    } else {
      await run(database);
    }
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
