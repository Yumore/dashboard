import 'package:dashboard/features/comic/picacomic/core/comic_source_data_store.dart';

/// In-memory [ComicSourceDataStore], used by tests and by callers that want a
/// non-persistent source registry.
class MemoryComicSourceStore implements ComicSourceDataStore {
  final Map<String, Map<String, dynamic>> entries = {};

  @override
  Future<Map<String, dynamic>?> read(String key) async {
    final value = entries[key];
    return value == null ? null : Map<String, dynamic>.from(value);
  }

  @override
  Future<void> write(String key, Map<String, dynamic> data) async {
    entries[key] = Map<String, dynamic>.from(data);
  }
}
