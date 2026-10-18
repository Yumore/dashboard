import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';

/// The shelf (书架) table: books the user saved.
abstract class ShelfStore {
  Future<List<FlutterNovelShelfEntry>> loadShelf();

  Future<void> saveShelfEntry(FlutterNovelShelfEntry entry);

  Future<void> removeShelfEntry(String bookId);

  /// Whether [bookId] is already on the shelf (drives the detail page button).
  Future<bool> containsShelfEntry(String bookId);
}

/// Reading progress, one row per book.
abstract class ProgressStore {
  Future<FlutterNovelProgress?> loadProgress(String bookId);

  Future<void> saveProgress(FlutterNovelProgress progress);

  Future<void> removeProgress(String bookId);
}

/// The chapter-content cache (the source's `NovelContentCacheManager`).
abstract class ChapterCacheStore {
  /// The cached content for [link], or null when nothing is cached.
  Future<NovelChapterContent?> loadChapter(String link);

  Future<void> saveChapter(String link, NovelChapterContent content);

  Future<void> removeChapter(String link);

  Future<void> clearChapters();
}

/// The three stores the feature needs, bundled so a page can be handed one
/// object. Tests build [InMemoryFlutterNovelStore]; production uses
/// [FlutterNovelSqfliteStore].
abstract class FlutterNovelStore
    implements ShelfStore, ProgressStore, ChapterCacheStore {
  /// Opens whatever the implementation needs. Safe to call more than once.
  Future<void> open();

  Future<void> close();
}
