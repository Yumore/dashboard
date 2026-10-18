import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_history_group.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_history_record.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';

/// `history` persistence: one row per watched `(anime, episode, review)` pair.
///
/// The history page groups rows by day, exactly like the source app: the day
/// list is paginated with `substr(date, 1, dateLength)`, then every anime of
/// that day collapses its rows into a `min..max` episode range per rewatch.
class AnimeTraceHistoryDao {
  AnimeTraceHistoryDao(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AnimeTraceExecutor _db;
  final DateTime Function() _clock;

  static const String _table = AnimeTraceSchema.historyTable;

  /// Marks one episode watched at [date] (defaults to now).
  Future<int> insertHistory({
    required int animeId,
    required int episodeNumber,
    int reviewNumber = 1,
    String? date,
  }) {
    return _db.rawInsert(
      'insert into $_table (date, anime_id, episode_number, review_number) '
      'values (?, ?, ?, ?)',
      <Object?>[
        date ?? _clock().toIso8601String(),
        animeId,
        episodeNumber,
        reviewNumber,
      ],
    );
  }

  Future<bool> hasWatched(
    int animeId,
    int episodeNumber, {
    int reviewNumber = 1,
  }) async {
    final rows = await _db.rawQuery(
      'select history_id from $_table where anime_id = ? and '
      'episode_number = ? and review_number = ? limit 1',
      <Object?>[animeId, episodeNumber, reviewNumber],
    );
    return rows.isNotEmpty;
  }

  Future<int> deleteHistory(
    int animeId,
    int episodeNumber, {
    int reviewNumber = 1,
  }) {
    return _db.rawDelete(
      'delete from $_table where anime_id = ? and episode_number = ? and '
      'review_number = ?',
      <Object?>[animeId, episodeNumber, reviewNumber],
    );
  }

  Future<int> deleteHistoryByAnimeId(int animeId) {
    return _db.rawDelete('delete from $_table where anime_id = ?', <Object?>[
      animeId,
    ]);
  }

  /// Raw episode number -> watch date for one anime, so the episode list can
  /// render check marks.
  Future<Map<int, String>> getWatchedEpisodeDates(
    int animeId, {
    int reviewNumber = 1,
  }) async {
    final rows = await _db.rawQuery(
      'select episode_number, max(date) as date from $_table '
      'where anime_id = ? and review_number = ? group by episode_number',
      <Object?>[animeId, reviewNumber],
    );
    return <int, String>{
      for (final row in rows)
        _asInt(row['episode_number']): '${row['date'] ?? ''}',
    };
  }

  Future<int> getCheckedEpisodeCount(
    int animeId, {
    int reviewNumber = 1,
  }) async {
    final rows = await _db.rawQuery(
      'select count(distinct episode_number) as cnt from $_table '
      'where anime_id = ? and review_number = ?',
      <Object?>[animeId, reviewNumber],
    );
    return _asInt(rows.first['cnt']);
  }

  /// Number of pages of the day-grouped history list.
  Future<int> getHistoryDayCount({int dateLength = 10}) async {
    final rows = await _db.rawQuery(
      'select count(*) as cnt from (select substr(date, 1, $dateLength) as d '
      'from $_table group by d)',
    );
    return _asInt(rows.first['cnt']);
  }

  /// One page of the day-grouped history list, newest day first.
  Future<List<AnimeTraceHistoryGroup>> getHistoryPageable({
    int page = 1,
    int pageSize = 20,
    int dateLength = 10,
  }) async {
    final normalizedPage = page < 1 ? 1 : page;
    final offset = (normalizedPage - 1) * pageSize;
    final dayRows = await _db.rawQuery(
      'select substr(date, 1, $dateLength) as dateSubstr from $_table '
      'group by dateSubstr order by dateSubstr desc limit ? offset ?',
      <Object?>[pageSize, offset],
    );

    final groups = <AnimeTraceHistoryGroup>[];
    for (final dayRow in dayRows) {
      final date = '${dayRow['dateSubstr'] ?? ''}';
      groups.add(AnimeTraceHistoryGroup(date, await _recordsOfDay(date)));
    }
    return groups;
  }

  /// Every anime watched on [date] with its per-rewatch episode range.
  Future<List<AnimeTraceHistoryRecord>> _recordsOfDay(String date) async {
    final likeDate = '$date%';
    final animeRows = await _db.rawQuery(
      'select distinct anime.anime_id, anime.anime_name, '
      'anime.anime_cover_url, anime.episode_start_number, '
      'anime.cal_episode_number_from_one '
      'from $_table, anime where $_table.date like ? '
      'and $_table.anime_id = anime.anime_id '
      'order by $_table.date desc',
      <Object?>[likeDate],
    );

    final records = <AnimeTraceHistoryRecord>[];
    for (final animeRow in animeRows) {
      final anime = AnimeTraceAnime.fromMap(animeRow);
      final reviewRows = await _db.rawQuery(
        'select distinct review_number from $_table where date like ? '
        'and anime_id = ? order by review_number desc',
        <Object?>[likeDate, anime.animeId],
      );
      for (final reviewRow in reviewRows) {
        final reviewNumber = _asInt(reviewRow['review_number']);
        final rangeRows = await _db.rawQuery(
          'select min(episode_number) as startEpisodeNumber, '
          'max(episode_number) as endEpisodeNumber from $_table '
          'where date like ? and anime_id = ? and review_number = ?',
          <Object?>[likeDate, anime.animeId, reviewNumber],
        );
        if (rangeRows.isEmpty) continue;
        final start = _asInt(rangeRows.first['startEpisodeNumber']);
        final end = _asInt(rangeRows.first['endEpisodeNumber']);
        records.add(
          AnimeTraceHistoryRecord(
            anime: anime,
            reviewNumber: reviewNumber,
            startEpisodeNumber: AnimeTraceEpisode.fixedEpisodeNumber(
              anime,
              start,
            ),
            endEpisodeNumber: AnimeTraceEpisode.fixedEpisodeNumber(anime, end),
          ),
        );
      }
    }
    return records;
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
