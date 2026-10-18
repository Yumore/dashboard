import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';

/// CRUD for collected anime plus the duplicate-name query used by the dedup
/// page.
class AnimeTraceAnimeDao {
  AnimeTraceAnimeDao(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AnimeTraceExecutor _db;
  final DateTime Function() _clock;

  static const String _selection =
      'select anime.*, '
      '(select count(distinct episode_number) from history '
      'where history.anime_id = anime.anime_id '
      'and history.review_number = anime.review_number) as checked_episode_cnt '
      'from anime';

  /// Inserts [anime] and returns the new row id. `anime_id` is always assigned
  /// by the database, never by the caller.
  Future<int> insertAnime(AnimeTraceAnime anime) {
    final values = anime.toMap()
      ..remove('anime_id')
      ..['last_mode_tag_time'] = _clock().toIso8601String();
    return _db.insertMap(AnimeTraceSchema.animeTable, values);
  }

  /// Inserts many anime inside one transaction and returns their new ids.
  ///
  /// Falls back to a plain sequential insert when the executor is a bare
  /// executor rather than an opened database (only the tests do that).
  Future<List<int>> insertAnimes(List<AnimeTraceAnime> animes) async {
    final ids = <int>[];
    if (animes.isEmpty) return ids;

    Future<void> insertAll(AnimeTraceExecutor executor) async {
      for (final anime in animes) {
        final values = anime.toMap()
          ..remove('anime_id')
          ..['last_mode_tag_time'] = _clock().toIso8601String();
        ids.add(await executor.insertMap(AnimeTraceSchema.animeTable, values));
      }
    }

    final database = _db;
    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction(insertAll);
    } else {
      await insertAll(database);
    }
    return ids;
  }

  Future<AnimeTraceAnime?> getAnimeById(int animeId) async {
    final rows = await _db.rawQuery(
      '$_selection where anime.anime_id = ?',
      <Object?>[animeId],
    );
    if (rows.isEmpty) return null;
    return AnimeTraceAnime.fromMap(rows.first);
  }

  /// The collection list, most recently touched first.
  Future<List<AnimeTraceAnime>> getAllAnimes() async {
    final rows = await _db.rawQuery(
      '$_selection order by coalesce(anime.last_mode_tag_time, \'\') desc, '
      'anime.anime_id desc',
    );
    return rows.map(AnimeTraceAnime.fromMap).toList();
  }

  /// All anime carrying [tagName].
  Future<List<AnimeTraceAnime>> getAnimesByTag(String tagName) async {
    final rows = await _db.rawQuery(
      '$_selection where anime.tag_name = ? '
      'order by coalesce(anime.last_mode_tag_time, \'\') desc',
      <Object?>[tagName],
    );
    return rows.map(AnimeTraceAnime.fromMap).toList();
  }

  /// Anime whose stored URL is [animeUrl]; the import flow treats a hit as
  /// "already collected".
  Future<AnimeTraceAnime?> getAnimeByAnimeUrl(String animeUrl) async {
    if (animeUrl.isEmpty) return null;
    final rows = await _db.rawQuery(
      '$_selection where anime.anime_url = ? limit 1',
      <Object?>[animeUrl],
    );
    if (rows.isEmpty) return null;
    return AnimeTraceAnime.fromMap(rows.first);
  }

  Future<bool> existAnimeName(String animeName) async {
    final rows = await _db.rawQuery(
      'select anime_id from anime where anime_name = ? limit 1',
      <Object?>[animeName],
    );
    return rows.isNotEmpty;
  }

  Future<bool> existAnimeUrl(String animeUrl) async {
    if (animeUrl.isEmpty) return false;
    final rows = await _db.rawQuery(
      'select anime_id from anime where anime_url = ? limit 1',
      <Object?>[animeUrl],
    );
    return rows.isNotEmpty;
  }

  Future<int> getAnimeCount() async {
    final rows = await _db.rawQuery('select count(anime_id) as cnt from anime');
    return _asInt(rows.first['cnt']);
  }

  /// Names grouped by tag, used to build the collection filter chips.
  Future<List<String>> getAllTags() async {
    final rows = await _db.rawQuery(
      'select distinct tag_name from anime '
      'where tag_name is not null and tag_name != \'\'',
    );
    return rows.map((row) => '${row['tag_name']}').toList();
  }

  /// The source app's duplicate query: every anime whose name occurs at least
  /// twice, ordered so duplicates sit next to each other.
  Future<List<AnimeTraceAnime>> getDupAnimes() async {
    final rows = await _db.rawQuery(
      'select anime.* from anime where anime_name in '
      '(select anime_name from anime group by anime_name '
      'having count(anime_name) >= 2) '
      'order by anime_name asc, anime.anime_id asc',
    );
    return rows.map(AnimeTraceAnime.fromMap).toList();
  }

  Future<int> updateAnimeCoverUrl(int animeId, String coverUrl) {
    return _db.rawUpdate(
      'update anime set anime_cover_url = ? where anime_id = ?',
      <Object?>[coverUrl, animeId],
    );
  }

  Future<int> updateAnimeTag(int animeId, String tagName) {
    return _db.rawUpdate(
      'update anime set tag_name = ?, last_mode_tag_time = ? where anime_id = ?',
      <Object?>[tagName, _clock().toIso8601String(), animeId],
    );
  }

  Future<int> updateEpisodeStartNumber(int animeId, int startNumber) {
    return _db.rawUpdate(
      'update anime set episode_start_number = ? where anime_id = ?',
      <Object?>[startNumber, animeId],
    );
  }

  /// Updates the scraped detail fields of an existing row.
  Future<int> updateAnimeInfo(AnimeTraceAnime anime) {
    return _db.rawUpdate(
      'update anime set anime_name = ?, anime_episode_cnt = ?, anime_desc = ?, '
      'anime_cover_url = ?, premiere_time = ?, name_another = ?, name_ori = ?, '
      'author_ori = ?, area = ?, play_status = ?, category = ?, '
      'production_company = ?, official_site = ?, anime_url = ?, '
      'climb_finished = ?, last_mode_tag_time = ? where anime_id = ?',
      <Object?>[
        anime.animeName,
        anime.animeEpisodeCnt,
        anime.animeDesc,
        anime.animeCoverUrl,
        anime.premiereTime,
        anime.nameAnother,
        anime.nameOri,
        anime.authorOri,
        anime.area,
        anime.playStatus,
        anime.category,
        anime.productionCompany,
        anime.officialSite,
        anime.animeUrl,
        anime.climbFinished ? 1 : 0,
        _clock().toIso8601String(),
        anime.animeId,
      ],
    );
  }

  /// Removes the anime and every row that belongs to it (history, notes,
  /// note images, labels and series links) in one transaction.
  Future<void> deleteAnimeById(int animeId) async {
    final database = _db;
    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction((txn) async {
        await _deleteRelated(txn, animeId);
      });
      return;
    }
    await _deleteRelated(database, animeId);
  }

  Future<void> _deleteRelated(AnimeTraceExecutor executor, int animeId) async {
    await executor.rawDelete(
      'delete from image where note_id in '
      '(select note_id from episode_note where anime_id = ?)',
      <Object?>[animeId],
    );
    await executor.rawDelete(
      'delete from episode_note where anime_id = ?',
      <Object?>[animeId],
    );
    await executor.rawDelete(
      'delete from history where anime_id = ?',
      <Object?>[animeId],
    );
    await executor.rawDelete(
      'delete from anime_label where anime_id = ?',
      <Object?>[animeId],
    );
    await executor.rawDelete(
      'delete from anime_series where anime_id = ?',
      <Object?>[animeId],
    );
    await executor.rawDelete('delete from anime where anime_id = ?', <Object?>[
      animeId,
    ]);
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
