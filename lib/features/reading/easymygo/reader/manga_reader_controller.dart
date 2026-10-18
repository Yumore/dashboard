import 'package:dashboard/features/reading/easymygo/component/manga_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_picture.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';

/// Manga reader state machine, ported from `MangaReadComponent` usage in
/// EasyMyGo's reader (chapter list → `getMangaPictures` → page cursor).
class MangaReaderController implements ReaderController {
  MangaReaderController({
    required this.component,
    required this.summary,
    required this.chapters,
  });

  final MangaComponent component;
  final BookSummary summary;
  final List<MangaChapter> chapters;

  ReaderState _state = const ReaderState(type: SourceType.manga);
  bool _busy = false;

  @override
  ReaderState get state => _state;

  @override
  int get chapterCount => chapters.length;

  @override
  Future<void> openChapter(int index) async {
    if (_busy) return;
    if (index < 0 || index >= chapters.length) return;
    final chapter = chapters[index];
    _state = _state.copyWith(
      status: ReaderStatus.loading,
      chapterIndex: index,
      chapterId: chapter.id,
      chapterLabel: chapter.label,
      pictures: const <MangaPicture>[],
      pages: const <String>[],
      pageIndex: 0,
      errorMsg: '',
    );
    _busy = true;
    try {
      final (payload, pictures) = await component.getMangaPictures(
        chapter,
        summary,
      );
      if (payload.isError) {
        _state = _state.copyWith(
          status: ReaderStatus.error,
          errorMsg: payload.errorMsg,
          payload: payload,
        );
        return;
      }
      if (pictures == null || pictures.isEmpty) {
        _state = _state.copyWith(
          status: ReaderStatus.error,
          errorMsg: '本章没有图片',
          payload: payload,
        );
        return;
      }
      _state = _state.copyWith(
        status: ReaderStatus.ready,
        pictures: pictures,
        pageIndex: 0,
        payload: payload,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: ReaderStatus.error,
        errorMsg: '$error',
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Future<void> nextChapter() => openChapter(_state.chapterIndex + 1);

  @override
  Future<void> previousChapter() => openChapter(_state.chapterIndex - 1);

  @override
  Future<void> nextPage() async {
    if (_state.status != ReaderStatus.ready) return;
    if (_state.pageIndex + 1 < _state.pageCount) {
      _state = _state.copyWith(pageIndex: _state.pageIndex + 1);
      return;
    }
    if (_state.chapterIndex + 1 < chapters.length) {
      await openChapter(_state.chapterIndex + 1);
    }
  }

  @override
  Future<void> previousPage() async {
    if (_state.status != ReaderStatus.ready) return;
    if (_state.pageIndex > 0) {
      _state = _state.copyWith(pageIndex: _state.pageIndex - 1);
      return;
    }
    if (_state.chapterIndex > 0) {
      await openChapter(_state.chapterIndex - 1);
      jumpToPage(_state.pageCount - 1);
    }
  }

  @override
  void jumpToPage(int index) {
    if (_state.pageCount <= 0) return;
    final clamped = index.clamp(0, _state.pageCount - 1);
    _state = _state.copyWith(pageIndex: clamped);
  }

  @override
  Future<void> restore(ReadingProgress progress) async {
    if (chapters.isEmpty) return;
    final index = progress.chapterIndex.clamp(0, chapters.length - 1);
    await openChapter(index);
    if (progress.pageIndex > 0) jumpToPage(progress.pageIndex);
  }

  @override
  ReadingProgress buildProgress({int? now}) => ReadingProgress(
    chapterId: _state.chapterId,
    chapterLabel: _state.chapterLabel,
    chapterIndex: _state.chapterIndex,
    pageIndex: _state.pageIndex,
    pageCount: _state.pageCount,
    updatedAt: now ?? DateTime.now().millisecondsSinceEpoch,
  );
}
