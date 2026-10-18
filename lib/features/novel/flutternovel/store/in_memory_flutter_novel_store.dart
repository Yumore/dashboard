import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';

/// An in-memory [FlutterNovelStore].
///
/// The host's sqflite providers are static and need a platform database, so the
/// tests (and any caller that wants an ephemeral reader) get this implementation
/// instead. Behaviour mirrors the sqflite one: the shelf is newest-first, saving
/// an existing book overwrites its row, and the chapter cache is keyed by the
/// chapter link.
class InMemoryFlutterNovelStore extends FlutterNovelStore {
  final Map<String, FlutterNovelShelfEntry> _shelf =
      <String, FlutterNovelShelfEntry>{};
  final Map<String, FlutterNovelProgress> _progress =
      <String, FlutterNovelProgress>{};
  final Map<String, NovelChapterContent> _chapters =
      <String, NovelChapterContent>{};

  bool opened = false;
  bool closed = false;

  /// Number of [loadChapter] calls, so tests can prove a cache hit avoided a
  /// second read of the content payload.
  int chapterLoads = 0;

  @override
  Future<void> open() async {
    opened = true;
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  @override
  Future<List<FlutterNovelShelfEntry>> loadShelf() async {
    final entries = _shelf.values.toList()
      ..sort((a, b) {
        final left = a.addedAt?.millisecondsSinceEpoch ?? 0;
        final right = b.addedAt?.millisecondsSinceEpoch ?? 0;
        return right.compareTo(left);
      });
    return entries;
  }

  @override
  Future<void> saveShelfEntry(FlutterNovelShelfEntry entry) async {
    _shelf[entry.bookId] = entry;
  }

  @override
  Future<void> removeShelfEntry(String bookId) async {
    _shelf.remove(bookId);
  }

  @override
  Future<bool> containsShelfEntry(String bookId) async =>
      _shelf.containsKey(bookId);

  @override
  Future<FlutterNovelProgress?> loadProgress(String bookId) async =>
      _progress[bookId];

  @override
  Future<void> saveProgress(FlutterNovelProgress progress) async {
    _progress[progress.bookId] = progress;
  }

  @override
  Future<void> removeProgress(String bookId) async {
    _progress.remove(bookId);
  }

  @override
  Future<NovelChapterContent?> loadChapter(String link) async {
    chapterLoads++;
    return _chapters[link];
  }

  @override
  Future<void> saveChapter(String link, NovelChapterContent content) async {
    _chapters[link] = content;
  }

  @override
  Future<void> removeChapter(String link) async {
    _chapters.remove(link);
  }

  @override
  Future<void> clearChapters() async {
    _chapters.clear();
  }

  /// The number of cached chapters (test helper).
  int get cachedChapterCount => _chapters.length;
}
