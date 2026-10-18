import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_memory_cache.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/foundation.dart';

/// 正文加载与预取（移植 eso `lib/page/content_page_manager.dart` 的 `ContentProvider`）。
///
/// 与原实现的差异：源实现还会把正文写进本地文件缓存（`CacheUtil` +
/// 存储权限），宿主只保留内存缓存（30 章 LRU），因此不需要任何权限；
/// 预取自带的 100ms 延时可通过 [prefetchDelay] 关掉（测试用）。
class EsoContentProvider extends ChangeNotifier {
  EsoContentProvider(
    this.searchItem, {
    EsoApiManager? api,
    EsoHistoryItemStore? historyStore,
    this.prefetchDelay = const Duration(milliseconds: 100),
  })  : _api = api,
        _historyStore = historyStore,
        _memoryCache = EsoMemoryCache<int, List<String>>(cacheSize: 30) {
    _ready = init();
  }

  final EsoSearchItem searchItem;
  final EsoApiManager? _api;
  final EsoHistoryItemStore? _historyStore;
  final Duration prefetchDelay;

  EsoApiManager get _manager => _api ?? EsoApiManager.instance;

  final EsoMemoryCache<int, List<String>> _memoryCache;

  /// 正文按空行/连续空白切成段落（源实现的 `RegExp(r"\n\s*|\s{2,}")`）。
  static final RegExp paragraphPattern = RegExp(r'\n\s*|\s{2,}');

  bool _showInfo = true;

  bool get showInfo => _showInfo;

  String _info = '';

  String get info => _info;

  Future<void>? _ready;

  Future<void>? get ready => _ready;

  /// 后台预取任务（源实现是 fire-and-forget，这里暴露出来便于测试等待）。
  Future<void>? prefetching;

  Future<void> init() async {
    try {
      if (searchItem.chapters == null || searchItem.chapters!.isEmpty) {
        _addInfo('目录为空 重新获取目录');
        searchItem.chapters =
            await _manager.getChapter(searchItem.originTag, searchItem.url);
        _addInfo('结束 得到${searchItem.chapters!.length}个章节');
      }
      _showInfo = false;
      notifyListeners();
    } catch (e) {
      _addInfo('$e');
    }
  }

  void _addInfo(String s) {
    _info += '\n$s';
    notifyListeners();
  }

  int get cachedChapterCount => _memoryCache.size;

  Future<List<String>> refresh() {
    return loadChapter(searchItem.durChapterIndex ?? 0, false, false);
  }

  Future<List<String>> loadChapter(
    int chapterIndex, [
    bool useCache = true,
    bool loadNext = true,
    bool shouldChangeIndex = true,
  ]) async {
    final chapters = searchItem.chapters ?? <EsoChapterItem>[];
    if (chapterIndex < 0 || chapterIndex >= chapters.length) {
      return <String>[];
    }
    final r = await _memoryCache.getValueOrSet(chapterIndex, () async {
      final chapter = chapters[chapterIndex];
      final content =
          await _manager.getContent(searchItem.originTag, chapter.url ?? '');
      chapter.contentUrl = EsoApi.contentUrl;
      final resp = content.join('\n').split(paragraphPattern);
      return resp;
    });

    if (shouldChangeIndex) await changeChapter(chapterIndex);

    if (loadNext) {
      prefetching = _prefetch(chapterIndex, useCache);
    }

    return r;
  }

  /// 预取后两章（源实现的 `chapterIndex + 2/3 < length` 判断）。
  Future<void> _prefetch(int chapterIndex, bool useCache) async {
    final chapters = searchItem.chapters ?? <EsoChapterItem>[];
    if (chapterIndex + 2 < chapters.length &&
        !_memoryCache.containsKey(chapterIndex + 1)) {
      if (prefetchDelay > Duration.zero) await Future<void>.delayed(prefetchDelay);
      await loadChapter(chapterIndex + 1, useCache, false, false);
    }
    if (chapterIndex + 3 < chapters.length &&
        !_memoryCache.containsKey(chapterIndex + 2)) {
      if (prefetchDelay > Duration.zero) await Future<void>.delayed(prefetchDelay);
      await loadChapter(chapterIndex + 2, useCache, false, false);
    }
  }

  Future<void> changeChapter(int index) async {
    await _historyStore?.insertOrUpdateHistoryItem(searchItem);
  }

  void clearCache() {
    _memoryCache.clear();
    notifyListeners();
  }
}
