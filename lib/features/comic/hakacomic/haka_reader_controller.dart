import 'package:flutter/foundation.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_fetch_chapter_images_payload.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_initial.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';

/// Chapter reader: fetches page images for one chapter and tracks position.
///
/// Ported from `haka_comic/lib/views/reader/reader.dart`. Deliberate
/// simplification: only vertical/horizontal paging and resume tracking are
/// kept; download, caching and volume-key handling live outside this port's
/// scope.
class HakaReaderController extends ChangeNotifier {
  HakaReaderController({
    required this.repository,
    required this.comicId,
    required List<HakaChapter> chapters,
    required this.readRecords,
    int initialOrder = 1,
    int initialPage = 1,
  }) : _chapters = [...chapters]..sort(
         (a, b) => a.order.compareTo(b.order),
       ),
       _order = initialOrder,
       _currentPage = (initialPage - 1).clamp(0, 1 << 31);

  final HakaRepository repository;

  final String comicId;

  final HakaReadRecordStore readRecords;

  final List<HakaChapter> _chapters;

  int _order;

  int _currentPage;

  List<HakaImageBase> _images = const [];

  HakaRequestState<List<HakaImageBase>> _state =
      const HakaInitial<List<HakaImageBase>>();

  bool _disposed = false;

  HakaRequestState<List<HakaImageBase>> get state => _state;

  List<HakaImageBase> get images => List.unmodifiable(_images);

  /// Chapters ascending by `order`.
  List<HakaChapter> get chapters => List.unmodifiable(_chapters);

  /// 1-based `order` of the chapter being read.
  int get order => _order;

  /// 0-based index of the visible page.
  int get currentIndex => _currentPage;

  /// 1-based page number used for persistence and the on-screen counter.
  int get displayPage => _currentPage + 1;

  int get totalPages => _images.length;

  HakaChapter? get chapter {
    if (_chapters.isEmpty) return null;
    return _chapters.firstWhere(
      (item) => item.order == _order,
      orElse: () => _chapters.first,
    );
  }

  bool get hasPreviousChapter => _chapterIndex > 0;

  bool get hasNextChapter => _chapterIndex >= 0 && _chapterIndex < _chapters.length - 1;

  bool get isLastPage => _images.isEmpty || _currentPage >= _images.length - 1;

  bool get isFinishedChapter => isLastPage && !hasNextChapter;

  double get progress =>
      _images.isEmpty ? 0 : (_currentPage + 1) / _images.length;

  int get _chapterIndex =>
      _chapters.indexWhere((item) => item.order == _order);

  /// Fetches the current chapter, then resumes at the last read page when the
  /// caller opened the chapter it belonged to.
  Future<void> load({int? resumePage}) async {
    _state = HakaLoading<List<HakaImageBase>>(
      _images.isEmpty ? null : _images,
    );
    _notify();
    try {
      _images = await repository.fetchChapterImages(
        HakaFetchChapterImagesPayload(id: comicId, order: _order),
      );
      final requested = resumePage != null && resumePage > 1 ? resumePage : null;
      _currentPage = _clamp(requested == null ? 0 : requested - 1);
      _state = HakaSuccess<List<HakaImageBase>>(List.unmodifiable(_images));
      _notify();
      await _persist();
    } catch (error) {
      _state = HakaFailure<List<HakaImageBase>>(error);
      _notify();
    }
  }

  Future<void> retry() => load(resumePage: _currentPage + 1);

  /// Called from the PageView; persists the new position.
  Future<void> onPageChanged(int index) async {
    if (index == _currentPage) return;
    _currentPage = _clamp(index);
    _notify();
    await _persist();
  }

  /// Jumps one page, used by keyboard/volume-style controls.
  Future<void> turnPage(int delta) => onPageChanged(_currentPage + delta);

  Future<void> nextChapter() async {
    if (!hasNextChapter) return;
    _order = _chapters[_chapterIndex + 1].order;
    _currentPage = 0;
    _notify();
    await load();
  }

  Future<void> previousChapter() async {
    if (!hasPreviousChapter) return;
    _order = _chapters[_chapterIndex - 1].order;
    _currentPage = 0;
    _notify();
    await load();
  }

  int _clamp(int index) {
    if (_images.isEmpty) return 0;
    if (index < 0) return 0;
    if (index >= _images.length) return _images.length - 1;
    return index;
  }

  /// Writes the current position through [HakaReadRecordStore]; the final page
  /// of the final chapter also marks the comic finished.
  Future<void> _persist() async {
    final current = chapter;
    if (current == null) return;
    final record = HakaReadRecord(
      comicId: comicId,
      chapterId: current.uid,
      chapterOrder: current.order,
      chapterTitle: current.title,
      pageNo: displayPage,
      finished: isFinishedChapter,
    );
    if (record.finished) {
      await readRecords.save(record);
      await readRecords.markFinished(comicId);
    } else {
      await readRecords.save(record);
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
