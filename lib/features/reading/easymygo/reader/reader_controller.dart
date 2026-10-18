import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';

/// Driving interface for the reader screen.
///
/// EasyMyGo split this across `MangaReadComponent` / `NovelReadComponent` plus
/// their riverpod view models; the port keeps one interface with two
/// implementations ([MangaReaderController], [NovelReaderController]) so the
/// reader page can hold either without knowing which business it drives.
abstract class ReaderController {
  ReaderState get state;

  /// Number of chapters currently addressable inside [openChapter].
  int get chapterCount;

  Future<void> openChapter(int index);

  Future<void> nextChapter();

  Future<void> previousChapter();

  Future<void> nextPage();

  Future<void> previousPage();

  void jumpToPage(int index);

  /// Restores a persisted cursor (chapter + page, and volume for novels).
  Future<void> restore(ReadingProgress progress);

  /// Snapshot for [LibraryStore.saveProgress].
  ReadingProgress buildProgress({int? now});
}
