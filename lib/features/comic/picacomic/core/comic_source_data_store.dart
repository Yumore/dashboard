/// Persistence contract for per-source account/setting data.
///
/// PicaComic wrote `${dataPath}/comic_source/<key>.data` JSON files; the host
/// has no shared data directory abstraction, so sources persist through
/// `shared_preferences` (see `data/shared_preferences_comic_source_store.dart`).
abstract class ComicSourceDataStore {
  Future<Map<String, dynamic>?> read(String key);

  Future<void> write(String key, Map<String, dynamic> data);
}
