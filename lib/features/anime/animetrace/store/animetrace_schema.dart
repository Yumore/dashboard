/// Plain-SQL schema of the AnimeTrace database.
///
/// Column names match the source app's shipped schema so an exported
/// `anime_trace.db` stays readable, and the statements live in a `const` list
/// (the same convention as the host's FlutterNovel store) so the schema can be
/// asserted without opening a platform database.
class AnimeTraceSchema {
  const AnimeTraceSchema._();

  static const String animeTable = 'anime';
  static const String historyTable = 'history';
  static const String episodeNoteTable = 'episode_note';
  static const String imageTable = 'image';
  static const String labelTable = 'label';
  static const String animeLabelTable = 'anime_label';
  static const String seriesTable = 'series';
  static const String animeSeriesTable = 'anime_series';

  /// Bumped only when a statement below changes in an incompatible way.
  static const int version = 1;

  static const List<String> statements = <String>[
    '''
    CREATE TABLE IF NOT EXISTS anime (
      anime_id INTEGER PRIMARY KEY AUTOINCREMENT,
      anime_name TEXT NOT NULL,
      anime_episode_cnt INTEGER NOT NULL DEFAULT 0,
      anime_desc TEXT,
      tag_name TEXT,
      last_mode_tag_time TEXT,
      anime_cover_url TEXT,
      premiere_time TEXT,
      name_another TEXT,
      name_ori TEXT,
      author_ori TEXT,
      area TEXT,
      play_status TEXT,
      category TEXT,
      production_company TEXT,
      official_site TEXT,
      anime_url TEXT,
      review_number INTEGER NOT NULL DEFAULT 1,
      rate INTEGER NOT NULL DEFAULT 0,
      episode_start_number INTEGER NOT NULL DEFAULT 1,
      cal_episode_number_from_one INTEGER NOT NULL DEFAULT 0,
      climb_finished INTEGER NOT NULL DEFAULT 0
    )
    ''',
    'CREATE INDEX IF NOT EXISTS index_anime_name ON anime (anime_name)',
    'CREATE INDEX IF NOT EXISTS index_anime_url ON anime (anime_url)',
    '''
    CREATE TABLE IF NOT EXISTS history (
      history_id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      anime_id INTEGER NOT NULL,
      episode_number INTEGER NOT NULL,
      review_number INTEGER NOT NULL DEFAULT 1
    )
    ''',
    'CREATE INDEX IF NOT EXISTS index_date ON history (date)',
    '''
    CREATE TABLE IF NOT EXISTS episode_note (
      note_id INTEGER PRIMARY KEY AUTOINCREMENT,
      anime_id INTEGER NOT NULL,
      episode_number INTEGER NOT NULL,
      review_number INTEGER NOT NULL DEFAULT 1,
      note_content TEXT,
      create_time TEXT,
      update_time TEXT
    )
    ''',
    '''
    CREATE TABLE IF NOT EXISTS image (
      image_id INTEGER PRIMARY KEY AUTOINCREMENT,
      note_id INTEGER,
      image_local_path TEXT,
      image_url TEXT,
      image_origin_name TEXT,
      order_idx INTEGER
    )
    ''',
    'CREATE TABLE IF NOT EXISTS label ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)',
    'CREATE TABLE IF NOT EXISTS anime_label ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'anime_id INTEGER NOT NULL, label_id INTEGER NOT NULL)',
    'CREATE TABLE IF NOT EXISTS series ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, '
        'desc TEXT, cover_url TEXT, create_time TEXT, update_time TEXT)',
    'CREATE TABLE IF NOT EXISTS anime_series ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'anime_id INTEGER NOT NULL, series_id INTEGER NOT NULL)',
  ];
}
