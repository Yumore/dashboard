import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/foundation.dart';

/// 目录分页 / 合并 / 去重（移植 eso `lib/model/chapter_page_provider.dart`）。
///
/// 目录是「无限滚动」的：每次向源要下一页，直到源返回空或返回和上一页
/// 完全相同的内容（`buildCheck` 指纹相同）为止；`page` 变成负数表示到底。
class EsoChapterPageProvider extends ChangeNotifier {
  EsoChapterPageProvider({
    required this.searchItem,
    EsoApiManager? api,
    EsoHistoryItemStore? historyStore,
  })  : _api = api,
        _historyStore = historyStore {
    if (searchItem.chapters == null) {
      _isLoading = true;
      _ready = initChapters();
    }
  }

  /// 目录列表样式（源实现 `BigList/SmallList/Grid`）。
  static const int bigList = 0;
  static const int smallList = 1;
  static const int grid = 2;

  final EsoSearchItem searchItem;

  final EsoApiManager? _api;
  final EsoHistoryItemStore? _historyStore;

  EsoApiManager get _manager => _api ?? EsoApiManager.instance;

  Future<void>? _ready;

  /// 构造时自动拉取的目录初始化任务（源实现在构造函数里 fire-and-forget）。
  Future<void>? get ready => _ready;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int _page = -1;

  int get page => _page;

  String checkContent = '';

  String getListStyleName([int? listStyle]) {
    listStyle ??= searchItem.chapterListStyle;
    switch (listStyle) {
      case bigList:
        return '大列表';
      case smallList:
        return '小列表';
      case grid:
        return '宫格';
      default:
        return '宫格';
    }
  }

  /// 目录指纹：条数 + 所有章节名（去空格）拼接，用于识别「源把最后一页
  /// 又返回了一遍」。
  String buildCheck(List<EsoChapterItem> chapters) {
    return '${chapters.length}${chapters.map((c) => (c.name ?? '').trim()).join('')}';
  }

  Future<void> initChapters() async {
    _page = 1;
    searchItem.chapters =
        await _manager.getChapter(searchItem.originTag, searchItem.url, page);
    searchItem.chapterUrl = EsoApi.chapterUrl;
    searchItem.durChapterIndex = 0;
    searchItem.durContentIndex = 1;
    if (searchItem.chapters!.isEmpty) {
      searchItem.durChapter = '';
      searchItem.chaptersCount = 0;
      searchItem.chapter = '';
      _page = 0;
    } else {
      searchItem.durChapter = searchItem.chapters!.first.name ?? '';
      searchItem.chaptersCount = searchItem.chapters!.length;
      searchItem.chapter = searchItem.chapters!.last.name;
      await loadChpaterWithPage(_page);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 逐页补全目录（源实现把参数 `page` 只用于结束标记，请求用 `_page`）。
  Future<void> loadChpaterWithPage(int page) async {
    if (_page == 1) {
      _page++;
      notifyListeners();
      checkContent = buildCheck(searchItem.chapters ?? <EsoChapterItem>[]);
    }

    Future<void> endCheck() async {
      _page = -page;
      checkContent = '';
      _isLoading = false;
      notifyListeners();
    }

    final durChapters =
        await _manager.getChapter(searchItem.originTag, searchItem.url, _page);
    if (durChapters.isEmpty) {
      await endCheck();
      return;
    }
    final newCheckContent = buildCheck(durChapters);
    if (checkContent == newCheckContent) {
      await endCheck();
      return;
    }
    searchItem.chapters!.addAll(durChapters);
    searchItem.chaptersCount = searchItem.chapters!.length;
    searchItem.chapter = searchItem.chapters!.last.name;
    _page++;
    notifyListeners();
    await loadChpaterWithPage(_page);
  }

  /// 重新拉取目录（对应源实现的 `refresh`）。
  Future<void> updateChapter() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    searchItem.chapters =
        await _manager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.chapterUrl = EsoApi.chapterUrl;
    searchItem.chaptersCount = searchItem.chapters!.length;
    if ((searchItem.chaptersCount ?? 0) > 0) {
      searchItem.chapter = searchItem.chapters!.last.name;
      _page = 1;
      await loadChpaterWithPage(_page);
    } else {
      _page = 0;
    }
    await _historyStore?.insertOrUpdateHistoryItem(searchItem);
    _isLoading = false;
    notifyListeners();
  }

  /// 切换章节：重置正文进度并落盘。
  Future<void> changeChapter(int index) async {
    final chapters = searchItem.chapters ?? <EsoChapterItem>[];
    if (index < 0 || index >= chapters.length) return;
    await _historyStore?.insertOrUpdateHistoryItem(searchItem);
    if (searchItem.durChapterIndex != index) {
      searchItem.durChapterIndex = index;
      searchItem.durChapter = chapters[index].name;
      searchItem.durContentIndex = 1;
      await _historyStore?.insertOrUpdateHistoryItem(searchItem);
      notifyListeners();
    }
  }

  void toggleReverse() {
    searchItem.reverseChapter = !(searchItem.reverseChapter ?? false);
    notifyListeners();
  }

  Future<void> changeListStyle(int listStyle) async {
    if (searchItem.chapterListStyle != listStyle) {
      searchItem.chapterListStyle = listStyle;
      await _historyStore?.insertOrUpdateHistoryItem(searchItem);
      notifyListeners();
    }
  }
}
