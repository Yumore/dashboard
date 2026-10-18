import 'package:dashboard/features/comic/picacomic/core/comic_source.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_registry.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';
import 'package:dashboard/features/comic/picacomic/data/history.dart';
import 'package:flutter/foundation.dart';

/// Controller of the picacomic reader.
///
/// Ports PicaComic lib/pages/reader/reading_logic.dart: `loadComicPages(id, ep)`
/// returns the ordered image urls, `getImageLoadingConfig(imageKey, comicId,
/// epId)` returns the headers each request needs, and the reading position is
/// written through `HistoryManager.saveReadHistory` (which bumps `time` and
/// keeps a set of already read chapters).
class PicacomicReaderController extends ChangeNotifier {
  PicacomicReaderController({
    required this.sourceKey,
    required this.comicId,
    this.chapterId,
    this.chapterName,
    HistoryManager? history,
    HistoryType? historyType,
    String? title,
    String? cover,
    int? chapterCount,
  }) : history = history ?? HistoryManager.instance,
       _historyType = historyType ?? HistoryType.forSourceKey(sourceKey),
       _title = title ?? comicId,
       _cover = cover ?? '',
       _chapterCount = chapterCount;

  final String sourceKey;
  final String comicId;
  final String? chapterId;
  final String? chapterName;
  final HistoryManager history;

  final HistoryType _historyType;
  final String _title;
  final String _cover;
  final int? _chapterCount;

  List<String> _images = const [];
  Map<String, String> _headers = const {};
  bool _loading = false;
  bool _disposed = false;
  String? _error;
  int _page = 0;

  ComicSource? get source => ComicSourceRegistry.find(sourceKey);

  List<String> get images => List.unmodifiable(_images);

  Map<String, String> get headers => Map.unmodifiable(_headers);

  bool get loading => _loading;

  String? get error => _error;

  /// Zero-based page index.
  int get page => _page;

  int get pageCount => _images.length;

  String get title => _title;

  String? get currentChapterName => chapterName;

  Future<void> load({int initialPage = 0}) async {
    final src = source;
    final loader = src?.loadComicPages;
    if (loader == null) {
      _error = 'Unknown comic source: $sourceKey';
      _notify();
      return;
    }
    _loading = true;
    _error = null;
    _notify();
    try {
      final res = await loader(comicId, chapterId);
      if (res.error) {
        _error = res.errorMessageWithoutNull;
      } else {
        _images = res.data;
        _page = initialPage.clamp(0, _images.isEmpty ? 0 : _images.length - 1);
        _headers = _readHeaders(src!, _images.isEmpty ? '' : _images.first);
        await _saveHistory();
      }
    } catch (e) {
      _error = '$e';
    }
    _loading = false;
    _notify();
  }

  /// Moves the reading cursor and persists it (reading_logic.dart saves on
  /// every page change so the history row survives a crash).
  Future<void> goTo(int page) async {
    if (_images.isEmpty) return;
    final target = page.clamp(0, _images.length - 1);
    if (target == _page) return;
    _page = target;
    _notify();
    await _saveHistory();
  }

  Future<void> nextPage() => goTo(_page + 1);

  Future<void> previousPage() => goTo(_page - 1);

  /// `getImageLoadingConfig` returns `{'headers': {...}}`; anything else is
  /// ignored, like the source's `Map<String, dynamic>` contract.
  Map<String, String> _readHeaders(ComicSource src, String imageKey) {
    final config = src.getImageLoadingConfig;
    if (config == null) return const {};
    try {
      final value = config(imageKey, comicId, chapterId ?? '');
      final headers = value['headers'];
      if (headers is Map) {
        return {
          for (final entry in headers.entries)
            '${entry.key}': '${entry.value}',
        };
      }
    } catch (_) {
      // A source that cannot describe the request falls back to no headers.
    }
    return const {};
  }

  Future<void> _saveHistory() async {
    final chapterIndex = int.tryParse(chapterId ?? '0') ?? 0;
    final history = History(
      type: _historyType,
      time: DateTime.now().millisecondsSinceEpoch,
      title: _title,
      cover: _cover,
      ep: chapterIndex,
      page: _page,
      target: comicId,
      maxPage: _chapterCount,
    );
    history.readEpisode.add(chapterIndex);
    await this.history.saveReadHistory(history);
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
