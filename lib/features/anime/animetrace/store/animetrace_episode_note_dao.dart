import 'package:dashboard/features/anime/animetrace/animetrace_anime.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_episode.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_note.dart';
import 'package:dashboard/features/anime/animetrace/animetrace_note_image.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_executor.dart';
import 'package:dashboard/features/anime/animetrace/store/animetrace_schema.dart';

/// `episode_note` (episode notes + the episode-0 rating note) and `image`
/// (locally stored note pictures) persistence.
///
/// Note content is written through bound parameters; the source app
/// hand-escaped quotes before interpolating SQL, which the port does not need.
class AnimeTraceEpisodeNoteDao {
  AnimeTraceEpisodeNoteDao(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AnimeTraceExecutor _db;
  final DateTime Function() _clock;

  static const String _noteTable = AnimeTraceSchema.episodeNoteTable;
  static const String _imageTable = AnimeTraceSchema.imageTable;

  /// The `episode_note` id for `(anime, episode, reviewNumber)`, or `null`.
  Future<int?> getNoteId(
    AnimeTraceAnime anime,
    AnimeTraceEpisode episode,
  ) async {
    final rows = await _db.rawQuery(
      'select note_id from $_noteTable where anime_id = ? and '
      'episode_number = ? and review_number = ? limit 1',
      <Object?>[anime.animeId, episode.number, episode.reviewNumber],
    );
    if (rows.isEmpty) return null;
    return _asInt(rows.first['note_id']);
  }

  /// The note id, inserting an empty note row when none exists yet (the note
  /// editor saves into it).
  Future<int> ensureNote(
    AnimeTraceAnime anime,
    AnimeTraceEpisode episode,
  ) async {
    final existing = await getNoteId(anime, episode);
    if (existing != null) return existing;
    final now = _clock().toIso8601String();
    return _db.rawInsert(
      'insert into $_noteTable '
      '(anime_id, episode_number, review_number, note_content, create_time, '
      'update_time) values (?, ?, ?, \'\', ?, ?)',
      <Object?>[anime.animeId, episode.number, episode.reviewNumber, now, now],
    );
  }

  /// Inserts the series' rating note (episode 0) and returns its id.
  Future<int> insertRateNote(int animeId) {
    final now = _clock().toIso8601String();
    return _db.rawInsert(
      'insert into $_noteTable '
      '(anime_id, episode_number, review_number, note_content, create_time, '
      'update_time) values (?, 0, 1, \'\', ?, ?)',
      <Object?>[animeId, now, now],
    );
  }

  /// Loads a note with its content and local images, or `null` when the note
  /// has never been created.
  Future<AnimeTraceNote?> loadNote(
    AnimeTraceAnime anime,
    AnimeTraceEpisode episode,
  ) async {
    final rows = await _db.rawQuery(
      'select note_id, note_content, create_time, update_time from $_noteTable '
      'where anime_id = ? and episode_number = ? and review_number = ? '
      'order by note_id desc limit 1',
      <Object?>[anime.animeId, episode.number, episode.reviewNumber],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final noteId = _asInt(row['note_id']);
    return AnimeTraceNote(
      id: noteId,
      anime: anime,
      episode: episode,
      noteContent: '${row['note_content'] ?? ''}',
      relativeLocalImages: await getImages(noteId),
      createTime: '${row['create_time'] ?? ''}',
      updateTime: '${row['update_time'] ?? ''}',
    );
  }

  /// All rating notes of one anime, newest first.
  Future<List<AnimeTraceNote>> getRateNotesByAnimeId(
    AnimeTraceAnime anime,
  ) async {
    final rows = await _db.rawQuery(
      'select note_id, note_content, create_time, update_time from $_noteTable '
      'where anime_id = ? and episode_number = 0 order by note_id desc',
      <Object?>[anime.animeId],
    );
    final notes = <AnimeTraceNote>[];
    for (final row in rows) {
      final noteId = _asInt(row['note_id']);
      notes.add(
        AnimeTraceNote(
          id: noteId,
          anime: anime,
          episode: AnimeTraceEpisode(0, reviewNumber: anime.reviewNumber),
          noteContent: '${row['note_content'] ?? ''}',
          relativeLocalImages: await getImages(noteId),
          createTime: '${row['create_time'] ?? ''}',
          updateTime: '${row['update_time'] ?? ''}',
        ),
      );
    }
    return notes;
  }

  /// Rating notes across all anime, newest first (the notes overview page).
  Future<List<AnimeTraceNote>> getRateNotes({
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await _db.rawQuery(
      'select anime_id, note_id, note_content, create_time, update_time '
      'from $_noteTable where episode_number = 0 '
      'order by create_time desc limit ? offset ?',
      <Object?>[limit, offset],
    );
    final notes = <AnimeTraceNote>[];
    for (final row in rows) {
      final noteId = _asInt(row['note_id']);
      notes.add(
        AnimeTraceNote(
          id: noteId,
          anime: AnimeTraceAnime(
            animeId: _asInt(row['anime_id']),
            animeName: '',
          ),
          episode: AnimeTraceEpisode(0),
          noteContent: '${row['note_content'] ?? ''}',
          relativeLocalImages: await getImages(noteId),
          createTime: '${row['create_time'] ?? ''}',
          updateTime: '${row['update_time'] ?? ''}',
        ),
      );
    }
    return notes;
  }

  Future<int> getRateNoteCount() async {
    final rows = await _db.rawQuery(
      'select count(note_id) as cnt from $_noteTable where episode_number = 0',
    );
    return _asInt(rows.first['cnt']);
  }

  Future<int> getEpisodeNoteCount() async {
    final rows = await _db.rawQuery(
      'select count(note_id) as cnt from $_noteTable where episode_number > 0',
    );
    return _asInt(rows.first['cnt']);
  }

  /// Anime ids having at least one note, most recently created first. Pass
  /// `isRateNote: false` for episode notes and `true` for rating notes.
  Future<List<int>> getAnimeIdsWithRecentNotes({bool? isRateNote}) async {
    var where = '';
    if (isRateNote == true) {
      where = 'where episode_number = 0';
    } else if (isRateNote == false) {
      where = 'where episode_number > 0';
    }
    final rows = await _db.rawQuery(
      'select distinct anime_id from $_noteTable $where '
      'order by note_id desc',
    );
    return rows.map((row) => _asInt(row['anime_id'])).toList();
  }

  /// Saves [content] and stamps `update_time`.
  Future<int> saveNoteContent(int noteId, String content) {
    return _db.rawUpdate(
      'update $_noteTable set note_content = ?, update_time = ? '
      'where note_id = ?',
      <Object?>[content, _clock().toIso8601String(), noteId],
    );
  }

  /// Appends a locally stored image to [noteId]; the returned id is the new
  /// `image_id`.
  Future<int> addImage(
    int noteId, {
    required String relativePath,
    String originName = '',
    String imageUrl = '',
  }) async {
    final orderRows = await _db.rawQuery(
      'select count(image_id) as cnt from $_imageTable where note_id = ?',
      <Object?>[noteId],
    );
    final orderIndex = _asInt(orderRows.first['cnt']);
    return _db.rawInsert(
      'insert into $_imageTable '
      '(note_id, image_local_path, image_url, image_origin_name, order_idx) '
      'values (?, ?, ?, ?, ?)',
      <Object?>[noteId, relativePath, imageUrl, originName, orderIndex],
    );
  }

  Future<List<AnimeTraceNoteImage>> getImages(int noteId) async {
    final rows = await _db.rawQuery(
      'select image_id, image_local_path from $_imageTable where note_id = ? '
      'order by order_idx, image_id',
      <Object?>[noteId],
    );
    return rows
        .map(
          (row) => AnimeTraceNoteImage(
            imageId: _asInt(row['image_id']),
            path: '${row['image_local_path'] ?? ''}',
          ),
        )
        .toList();
  }

  Future<int> deleteImage(int imageId) {
    return _db.rawDelete(
      'delete from $_imageTable where image_id = ?',
      <Object?>[imageId],
    );
  }

  /// Deletes a note together with its image rows.
  Future<void> deleteNote(int noteId) async {
    final database = _db;
    Future<void> run(AnimeTraceExecutor executor) async {
      await executor.rawDelete(
        'delete from $_imageTable where note_id = ?',
        <Object?>[noteId],
      );
      await executor.rawDelete(
        'delete from $_noteTable where note_id = ?',
        <Object?>[noteId],
      );
    }

    if (database is AnimeTraceExecutorDatabase) {
      await database.transaction(run);
    } else {
      await run(database);
    }
  }

  /// Note ids of one anime, newest first; used by the series detail page to
  /// mark which episodes carry notes.
  Future<Set<int>> getNotedEpisodeNumbers(
    int animeId, {
    int reviewNumber = 1,
  }) async {
    final rows = await _db.rawQuery(
      'select distinct episode_number from $_noteTable '
      'where anime_id = ? and review_number = ?',
      <Object?>[animeId, reviewNumber],
    );
    return rows.map((row) => _asInt(row['episode_number'])).toSet();
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
