import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_series.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';

/// `series` plus the `anime_series` join table.
///
/// A series groups several collected anime (franchises, seasons). Membership is
/// many-to-many, exactly as in the source app.
class AnimeTraceSeriesDao {
  AnimeTraceSeriesDao(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AnimeTraceExecutor _db;
  final DateTime Function() _clock;

  static const String _table = AnimeTraceSchema.seriesTable;
  static const String _joinTable = AnimeTraceSchema.animeSeriesTable;

  /// Mirrors `AnimeTraceAnimeDao`'s projection so lists inside a series show
  /// real progress.
  static const String _animeSelection =
      'select anime.*, '
      '(select count(distinct episode_number) from history '
      'where history.anime_id = anime.anime_id '
      'and history.review_number = anime.review_number) as checked_episode_cnt '
      'from anime inner join $_joinTable '
      'on $_joinTable.anime_id = anime.anime_id';

  Future<int> insert(String name, {String desc = '', String coverUrl = ''}) {
    final now = _clock().toIso8601String();
    return _db.rawInsert(
      'insert into $_table (name, desc, cover_url, create_time, update_time) '
      'values (?, ?, ?, ?, ?)',
      <Object?>[name, desc, coverUrl, now, now],
    );
  }

  Future<int> update(int id, {String? name, String? desc, String? coverUrl}) {
    final assignments = <String>[];
    final args = <Object?>[];
    if (name != null) {
      assignments.add('name = ?');
      args.add(name);
    }
    if (desc != null) {
      assignments.add('desc = ?');
      args.add(desc);
    }
    if (coverUrl != null) {
      assignments.add('cover_url = ?');
      args.add(coverUrl);
    }
    assignments.add('update_time = ?');
    args.add(_clock().toIso8601String());
    args.add(id);
    return _db.rawUpdate(
      'update $_table set ${assignments.join(', ')} where id = ?',
      args,
    );
  }

  /// Deletes a series and its membership rows; the anime themselves stay.
  Future<void> delete(int id) async {
    final database = _db;
    Future<void> run(AnimeTraceExecutor executor) async {
      await executor.rawDelete(
        'delete from $_joinTable where series_id = ?',
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

  Future<List<AnimeTraceSeries>> getAll({bool needAnimes = false}) async {
    final rows = await _db.rawQuery(
      'select id, name, desc, cover_url, create_time, update_time from '
      '$_table order by id',
    );
    final series = rows.map(AnimeTraceSeries.fromMap).toList();
    if (needAnimes) await _fillAnimes(series);
    return series;
  }

  Future<List<AnimeTraceSeries>> search(
    String keyword, {
    bool needAnimes = false,
  }) async {
    final rows = await _db.rawQuery(
      'select id, name, desc, cover_url, create_time, update_time from '
      '$_table where name like ? order by id',
      <Object?>['%$keyword%'],
    );
    final series = rows.map(AnimeTraceSeries.fromMap).toList();
    if (needAnimes) await _fillAnimes(series);
    return series;
  }

  Future<AnimeTraceSeries?> getById(int id, {bool needAnimes = true}) async {
    final rows = await _db.rawQuery(
      'select id, name, desc, cover_url, create_time, update_time from '
      '$_table where id = ? limit 1',
      <Object?>[id],
    );
    if (rows.isEmpty) return null;
    final series = AnimeTraceSeries.fromMap(rows.first);
    if (needAnimes) {
      series.animes.addAll(await getAnimesBySeriesId(id));
    }
    return series;
  }

  Future<bool> existName(String name) async {
    final rows = await _db.rawQuery(
      'select id from $_table where name = ? limit 1',
      <Object?>[name],
    );
    return rows.isNotEmpty;
  }

  Future<int> addAnimeToSeries(int animeId, int seriesId) {
    return _db.rawInsert(
      'insert into $_joinTable (anime_id, series_id) values (?, ?)',
      <Object?>[animeId, seriesId],
    );
  }

  Future<int> deleteAnimeFromSeries(int animeId, int seriesId) {
    return _db.rawDelete(
      'delete from $_joinTable where anime_id = ? and series_id = ?',
      <Object?>[animeId, seriesId],
    );
  }

  Future<int> deleteByAnimeId(int animeId) {
    return _db.rawDelete(
      'delete from $_joinTable where anime_id = ?',
      <Object?>[animeId],
    );
  }

  Future<List<int>> getSeriesIdsByAnimeId(int animeId) async {
    final rows = await _db.rawQuery(
      'select series_id from $_joinTable where anime_id = ? order by series_id',
      <Object?>[animeId],
    );
    return rows.map((row) => _asInt(row['series_id'])).toList();
  }

  Future<List<AnimeTraceSeries>> getSeriesByAnimeId(int animeId) async {
    final rows = await _db.rawQuery(
      'select series.id, series.name, series.desc, series.cover_url, '
      'series.create_time, series.update_time from $_table '
      'inner join $_joinTable on $_table.id = $_joinTable.series_id '
      'where $_joinTable.anime_id = ? order by $_table.id',
      <Object?>[animeId],
    );
    return rows.map(AnimeTraceSeries.fromMap).toList();
  }

  Future<List<AnimeTraceAnime>> getAnimesBySeriesId(int seriesId) async {
    final rows = await _db.rawQuery(
      '$_animeSelection where $_joinTable.series_id = ? '
      'order by anime.anime_id',
      <Object?>[seriesId],
    );
    return rows.map(AnimeTraceAnime.fromMap).toList();
  }

  /// Anime that belong to **all** of [seriesIds] (the source app's
  /// `GROUP BY anime_id HAVING COUNT(*) = n` query).
  Future<List<AnimeTraceAnime>> getAnimesBySeriesIds(
    List<int> seriesIds,
  ) async {
    if (seriesIds.isEmpty) return <AnimeTraceAnime>[];
    final placeholders = List<String>.filled(seriesIds.length, '?').join(', ');
    final rows = await _db.rawQuery(
      'select anime.*, '
      '(select count(distinct episode_number) from history '
      'where history.anime_id = anime.anime_id '
      'and history.review_number = anime.review_number) as checked_episode_cnt '
      'from anime inner join $_joinTable '
      'on anime.anime_id = $_joinTable.anime_id '
      'where $_joinTable.series_id in ($placeholders) '
      'group by anime.anime_id having count(*) = ? order by anime.anime_id',
      <Object?>[...seriesIds, seriesIds.length],
    );
    return rows.map(AnimeTraceAnime.fromMap).toList();
  }

  Future<void> setAnimeSeries(int animeId, List<int> seriesIds) async {
    final database = _db;
    Future<void> run(AnimeTraceExecutor executor) async {
      await executor.rawDelete(
        'delete from $_joinTable where anime_id = ?',
        <Object?>[animeId],
      );
      for (final seriesId in seriesIds) {
        await executor.rawInsert(
          'insert into $_joinTable (anime_id, series_id) values (?, ?)',
          <Object?>[animeId, seriesId],
        );
      }
    }

    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction(run);
    } else {
      await run(database);
    }
  }

  Future<void> _fillAnimes(List<AnimeTraceSeries> series) async {
    for (final item in series) {
      if (item.id <= 0) continue;
      item.animes.addAll(await getAnimesBySeriesId(item.id));
    }
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
