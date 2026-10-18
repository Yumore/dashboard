import 'dart:async';

import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:dashboard/features/novel/flutternovel/api/api_result.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_progress.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_source.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter_content.dart';
import 'package:dashboard/features/novel/flutternovel/models/reader_config.dart';
import 'package:dashboard/features/novel/flutternovel/reader/content_state.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_page_turn_engine.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_host.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_canvas_page.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_content_provider.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_page_content_config.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Thrown when a chapter's text cannot be loaded (offline, or the upstream
/// chapter-up service returned nothing).
class NovelChapterLoadException implements Exception {
  NovelChapterLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Drives the reader: loads and paginates one chapter at a time, remembers the
/// position, and owns the [NovelPageTurnEngine] for all three page-turn
/// animations.
///
/// It implements [ReaderAnimationHost] so the engine can read the surrounding
/// pages and turn them without knowing anything about storage or networking.
/// The widget layer only paints what this exposes and forwards gestures.
class NovelReaderController extends ChangeNotifier
    implements ReaderAnimationHost {
  NovelReaderController({
    required this.api,
    required this.store,
    required this.cache,
    required this.bookId,
    this.title = '',
  });

  final ZssqApi api;
  final FlutterNovelStore store;
  final NovelChapterCache cache;
  final String bookId;
  String title;

  /// The `atoc` catalog currently loaded, and its default source.
  NovelBookChapter? catalog;
  String catalogSource = '';

  FlutterNovelReaderConfig config = FlutterNovelReaderConfig();
  Size viewportSize = Size.zero;

  List<NovelChapter> _chapters = const <NovelChapter>[];
  List<ReaderPageContentConfig> _pages = <ReaderPageContentConfig>[];

  int _chapterIndex = 0;
  int _pageIndex = 0;
  String? _content;
  ContentState _contentState = ContentState.normal;
  bool _loading = false;
  String? _error;

  late final NovelPageTurnEngine engine = NovelPageTurnEngine(
    host: this,
    type: config.currentAnimationMode,
  );

  // ---------------------------------------------------------------------------
  // Exposed state
  // ---------------------------------------------------------------------------

  List<NovelChapter> get chapters => _chapters;

  int get chapterIndex => _chapterIndex;

  NovelChapter? get currentChapter =>
      _chapterIndex >= 0 && _chapterIndex < _chapters.length
      ? _chapters[_chapterIndex]
      : null;

  /// The chapter the reader should show progress for (1-based for display).
  String get currentChapterTitle =>
      currentChapter?.title ?? '第 ${_chapterIndex + 1} 章';

  List<ReaderPageContentConfig> get pages => _pages;

  int get pageIndex => _pageIndex;

  int get pageCount => _pages.length;

  ContentState get contentState => _contentState;

  bool get loading => _loading;

  String? get error => _error;

  double get progressRatio {
    if (_chapters.isEmpty) return 0;
    final chapterFraction = _pages.isEmpty
        ? 0.0
        : (_pageIndex + 1) / _pages.length;
    return ((_chapterIndex + chapterFraction) / _chapters.length).clamp(0.0, 1.0);
  }

  NovelPageTurnState get turnState => engine.state;

  /// The paragraphs of the page currently shown.
  List<String> get currentParagraphs => _pageIndex < _pages.length
      ? _pages[_pageIndex].paragraphContents
      : const <String>[];

  List<String> get nextParagraphs => _pageIndex + 1 < _pages.length
      ? _pages[_pageIndex + 1].paragraphContents
      : const <String>[];

  List<String> get preParagraphs =>
      _pageIndex - 1 >= 0 && _pageIndex - 1 < _pages.length
      ? _pages[_pageIndex - 1].paragraphContents
      : const <String>[];

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  /// Installs the catalog (already fetched by the book page when it could) and
  /// restores the saved progress. When [catalog] is null the caller can call
  /// [loadCatalog] afterwards.
  Future<void> bindCatalog(
    NovelBookChapter? value, {
    FlutterNovelProgress? progress,
  }) async {
    if (value != null) {
      catalog = value;
      catalogSource = value.source ?? '';
      _chapters = value.chapters;
    }
    final saved = progress ?? await store.loadProgress(bookId);
    if (saved != null && _chapters.isNotEmpty) {
      _chapterIndex = saved.chapterIndex.clamp(0, _chapters.length - 1);
      _pageIndex = saved.pageIndex < 0 ? 0 : saved.pageIndex;
    }
    await loadChapter(_chapterIndex, pageIndex: _pageIndex);
  }

  /// Fetches the first available book source's catalog.
  Future<bool> loadCatalog() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final sources = await api.getNovelSource(bookId);
      final list = sources.data ?? const <NovelBookSource>[];
      if (!sources.isSuccess || list.isEmpty) {
        _fail('没有可用的书源');
        return false;
      }
      final source = list.first;
      final result = await api.getNovelCatalog(source.id ?? '');
      final value = result.data;
      if (!result.isSuccess || value == null || value.chapters.isEmpty) {
        _fail('目录加载失败');
        return false;
      }
      catalog = value;
      catalogSource = source.id ?? '';
      _chapters = value.chapters;
      _loading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _fail('目录加载失败: $error');
      return false;
    }
  }

  /// Loads (or restores from cache) and paginates one chapter.
  Future<void> loadChapter(int index, {int pageIndex = 0}) async {
    if (index < 0 || index >= _chapters.length) return;
    _chapterIndex = index;
    _pageIndex = 0;
    _pages = const <ReaderPageContentConfig>[];
    _contentState = ContentState.normal;
    _loading = true;
    _error = null;
    notifyListeners();

    final link = _chapters[index].link ?? '';
    try {
      final cached = await cache.get(link);
      final content = cached ?? await _fetch(link);
      _content = content.cpContent ?? '';
      if (_content!.isEmpty) {
        _contentState = ContentState.notFound;
      }
      _paginate();
    } on NovelChapterLoadException catch (error) {
      _contentState = ContentState.netError;
      _error = error.message;
    } catch (error) {
      _contentState = ContentState.netError;
      _error = '$error';
    }

    if (_pages.isEmpty && _contentState == ContentState.normal) {
      _contentState = ContentState.notFound;
    }
    _pageIndex = pageIndex.clamp(0, _pages.isEmpty ? 0 : _pages.length - 1);
    _loading = false;
    notifyListeners();
  }

  Future<NovelChapterContent> _fetch(String link) async {
    final ApiResult<NovelChapterContent> result = await api.getChapterContent(
      link,
    );
    final value = result.data;
    if (!result.isSuccess || value == null || value.isEmpty) {
      throw NovelChapterLoadException('章节内容加载失败');
    }
    await cache.put(link, value);
    return value;
  }

  void _paginate() {
    _pages = ReaderContentProvider.getChapterPageContentConfigList(
      _chapters[_chapterIndex].novelId?.hashCode ?? _chapterIndex,
      _content,
      viewportSize.height,
      viewportSize.width,
      config.fontSize,
      config.lineHeight,
      config.paragraphSpacing,
    );
  }

  void _fail(String message) {
    _loading = false;
    _error = message;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Viewport / config
  // ---------------------------------------------------------------------------

  void setViewport(Size size) {
    if (size == viewportSize || size.isEmpty) return;
    viewportSize = size;
    engine.setViewportSize(size);
    _paginate();
    _pageIndex = _pageIndex.clamp(0, _pages.isEmpty ? 0 : _pages.length - 1);
    notifyListeners();
  }

  void applyConfig(FlutterNovelReaderConfig value) {
    final animationChanged =
        value.currentAnimationMode != config.currentAnimationMode;
    config = value;
    if (animationChanged) engine.setType(value.currentAnimationMode);
    if (viewportSize.isEmpty) return;
    _paginate();
    _pageIndex = _pageIndex.clamp(0, _pages.isEmpty ? 0 : _pages.length - 1);
    notifyListeners();
  }

  /// Switching page-turn animation at runtime — the "working switch" the page
  /// exposes in the reader's bottom bar.
  bool setAnimationType(int value) {
    final changed = engine.setType(value);
    if (!changed) return false;
    final next = config.copy();
    next.currentAnimationMode = value;
    config = next;
    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Page navigation
  // ---------------------------------------------------------------------------

  @override
  bool isCanGoNext() {
    if (_pageIndex < _pages.length - 1) return true;
    return _chapterIndex < _chapters.length - 1 && _chapters.isNotEmpty;
  }

  @override
  bool isCanGoPre() {
    if (_pageIndex > 0) return true;
    return _chapterIndex > 0;
  }

  @override
  void nextPage() {
    if (_pageIndex < _pages.length - 1) {
      _pageIndex++;
      _persistProgress();
      notifyListeners();
      return;
    }
    if (_chapterIndex < _chapters.length - 1) {
      final next = _chapterIndex + 1;
      _chapterIndex = next;
      _pageIndex = 0;
      unawaited(loadChapter(next));
    }
  }

  @override
  void prePage() {
    if (_pageIndex > 0) {
      _pageIndex--;
      _persistProgress();
      notifyListeners();
      return;
    }
    if (_chapterIndex > 0) {
      final previous = _chapterIndex - 1;
      _chapterIndex = previous;
      _pageIndex = 0;
      unawaited(loadChapter(previous));
    }
  }

  /// Jumps straight to a chapter (used by the catalog sheet).
  Future<void> openChapter(int index) async {
    if (index == _chapterIndex && _pages.isNotEmpty) return;
    await loadChapter(index);
  }

  /// Jumps to a page of the chapter currently shown (used by the progress
  /// slider).
  void jumpToPage(int index) {
    if (_pages.isEmpty) return;
    final target = index.clamp(0, _pages.length - 1);
    if (target == _pageIndex) return;
    _pageIndex = target;
    _persistProgress();
    notifyListeners();
  }

  /// The chapter number at which each catalog entry sits, for the catalog list.
  int get chapterCount => _chapters.length;

  @override
  ReaderCanvasPage? getCurrentPage() =>
      ReaderCanvasPage(pageIndex: _pageIndex);

  @override
  ReaderCanvasPage? getNextPage() =>
      isCanGoNext() ? ReaderCanvasPage(pageIndex: _pageIndex + 1) : null;

  @override
  ReaderCanvasPage? getPrePage() =>
      isCanGoPre() ? ReaderCanvasPage(pageIndex: _pageIndex - 1) : null;

  @override
  Paint get bgPaint => Paint()..color = config.currentCanvasBgColor;

  // ---------------------------------------------------------------------------
  // Gestures — forwarded to the page-turn engine
  // ---------------------------------------------------------------------------

  void onTouchBegin(Offset position) {
    engine.begin(position);
    notifyListeners();
  }

  void onTouchUpdate(Offset position) {
    engine.update(position);
    notifyListeners();
  }

  void onTouchEnd({double velocity = 0, bool cancelled = false}) {
    engine.end(velocity: velocity, cancelled: cancelled);
    notifyListeners();
  }

  /// Drives the running confirm/cancel animation (0→1).
  void onAnimationTick(double value) {
    engine.animationValue(value);
    notifyListeners();
  }

  /// The animation controller completed; applies a confirmed turn.
  void onAnimationCompleted() {
    if (engine.animationCompleted()) _persistProgress();
    notifyListeners();
  }

  void _persistProgress() {
    final chapter = currentChapter;
    unawaited(
      store.saveProgress(
        FlutterNovelProgress(
          bookId: bookId,
          chapterIndex: _chapterIndex,
          pageIndex: _pageIndex,
          chapterId: chapter?.id ?? '',
          chapterTitle: chapter?.title ?? '',
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    engine.setViewportSize(Size.zero);
    super.dispose();
  }
}
