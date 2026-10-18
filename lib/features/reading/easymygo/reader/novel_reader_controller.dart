import 'package:dashboard/features/reading/easymygo/component/novel_component.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';
import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';
import 'package:dashboard/features/reading/easymygo/reader/novel_paginator.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_controller.dart';
import 'package:dashboard/features/reading/easymygo/reader/reader_state.dart';

/// Novel reader state machine.
///
/// Ported from EasyMyGo's novel read path: the detail page lists volumes, a
/// volume lazily loads its chapters (`getNovelChapters`) and a chapter loads its
/// body (`loadNovelChapter`) before layout. The port's substitution for layout
/// pagination is [NovelPaginator].
class NovelReaderController implements ReaderController {
  NovelReaderController({
    required this.component,
    required this.summary,
    required this.volumes,
    this.paginator = const NovelPaginator(),
  });

  final NovelComponent component;
  final BookSummary summary;
  final List<NovelVolume> volumes;
  final NovelPaginator paginator;

  List<NovelChapter> _chapters = <NovelChapter>[];
  ReaderState _state = const ReaderState(type: SourceType.novel);
  bool _busy = false;

  List<NovelChapter> get chapters => List<NovelChapter>.unmodifiable(_chapters);

  @override
  ReaderState get state => _state;

  @override
  int get chapterCount => _chapters.length;

  /// Loads the chapter list of [index] into memory.
  Future<bool> openVolume(int index) async {
    if (index < 0 || index >= volumes.length) return false;
    final volume = volumes[index];
    _state = _state.copyWith(
      status: ReaderStatus.loading,
      volumeIndex: index,
      volumeId: volume.id,
      volumeLabel: volume.label,
      chapterIndex: 0,
      chapterId: '',
      chapterLabel: '',
      pages: const <String>[],
      pageIndex: 0,
      errorMsg: '',
    );
    final (payload, chapters) = await component.getNovelChapters(
      volume,
      summary,
    );
    if (payload.isError) {
      _state = _state.copyWith(
        status: ReaderStatus.error,
        errorMsg: payload.errorMsg,
        payload: payload,
      );
      return false;
    }
    if (chapters == null || chapters.isEmpty) {
      _state = _state.copyWith(
        status: ReaderStatus.error,
        errorMsg: '本卷没有章节',
        payload: payload,
      );
      return false;
    }
    _chapters = chapters;
    return true;
  }

  @override
  Future<void> openChapter(int index) async {
    if (_busy) return;
    if (_chapters.isEmpty) return;
    if (index < 0 || index >= _chapters.length) return;
    final chapter = _chapters[index];
    _state = _state.copyWith(
      status: ReaderStatus.loading,
      chapterIndex: index,
      chapterId: chapter.id,
      chapterLabel: chapter.label,
      pages: const <String>[],
      pageIndex: 0,
      errorMsg: '',
    );
    _busy = true;
    try {
      final (payload, content) = await component.loadNovelChapter(
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
      final pages = paginator.paginate(content);
      if (pages.isEmpty) {
        _state = _state.copyWith(
          status: ReaderStatus.error,
          errorMsg: '本章内容为空',
          payload: payload,
        );
        return;
      }
      _state = _state.copyWith(
        status: ReaderStatus.ready,
        pages: pages,
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
  Future<void> nextChapter() async {
    if (_chapters.isEmpty) return;
    if (_state.chapterIndex + 1 < _chapters.length) {
      await openChapter(_state.chapterIndex + 1);
      return;
    }
    if (_state.volumeIndex + 1 < volumes.length) {
      if (await openVolume(_state.volumeIndex + 1)) await openChapter(0);
    }
  }

  @override
  Future<void> previousChapter() async {
    if (_chapters.isEmpty) return;
    if (_state.chapterIndex > 0) {
      await openChapter(_state.chapterIndex - 1);
      return;
    }
    if (_state.volumeIndex > 0) {
      final previousVolume = _state.volumeIndex - 1;
      if (await openVolume(previousVolume)) {
        await openChapter(_chapters.length - 1);
      }
    }
  }

  @override
  Future<void> nextPage() async {
    if (_state.status != ReaderStatus.ready) return;
    if (_state.pageIndex + 1 < _state.pageCount) {
      _state = _state.copyWith(pageIndex: _state.pageIndex + 1);
      return;
    }
    await nextChapter();
  }

  @override
  Future<void> previousPage() async {
    if (_state.status != ReaderStatus.ready) return;
    if (_state.pageIndex > 0) {
      _state = _state.copyWith(pageIndex: _state.pageIndex - 1);
      return;
    }
    if (_chapters.isEmpty) return;
    if (_state.chapterIndex > 0) {
      await openChapter(_state.chapterIndex - 1);
      jumpToPage(_state.pageCount - 1);
      return;
    }
    if (_state.volumeIndex > 0) {
      if (await openVolume(_state.volumeIndex - 1)) {
        await openChapter(_chapters.length - 1);
        jumpToPage(_state.pageCount - 1);
      }
    }
  }

  @override
  void jumpToPage(int index) {
    if (_state.pageCount <= 0) return;
    _state = _state.copyWith(pageIndex: index.clamp(0, _state.pageCount - 1));
  }

  @override
  Future<void> restore(ReadingProgress progress) async {
    if (volumes.isEmpty) return;
    final volumeIndex = progress.volumeIndex.clamp(0, volumes.length - 1);
    if (!await openVolume(volumeIndex)) return;
    if (_chapters.isEmpty) return;
    await openChapter(progress.chapterIndex.clamp(0, _chapters.length - 1));
    if (progress.pageIndex > 0) jumpToPage(progress.pageIndex);
  }

  @override
  ReadingProgress buildProgress({int? now}) => ReadingProgress(
    chapterId: _state.chapterId,
    chapterLabel: _state.chapterLabel,
    chapterIndex: _state.chapterIndex,
    pageIndex: _state.pageIndex,
    pageCount: _state.pageCount,
    volumeId: _state.volumeId,
    volumeLabel: _state.volumeLabel,
    volumeIndex: _state.volumeIndex,
    updatedAt: now ?? DateTime.now().millisecondsSinceEpoch,
  );
}
