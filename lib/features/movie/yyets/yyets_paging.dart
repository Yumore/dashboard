/// 源工程 `LoadingPageState.loadMore` 的分页状态。
///
/// 源工程用 `LoadingStatus` 枚举 + 一个 `_page` 计数器驱动“上拉加载更多”：
/// 返回空列表即 `NO_MORE`，否则 `_page++`。移植版把这段状态显式建模出来，
/// 页面和测试都能直接断言翻页行为，而不必复刻 widget 生命周期。
class YyetsPaging<T> {
  YyetsPaging({List<T>? items, this.page = 1}) : items = items ?? <T>[];

  /// 已经取到的全部条目（源工程的 `items`）。
  final List<T> items;

  /// 下一次要请求的页码，从 1 开始（源工程的 `_page`）。
  int page;

  /// 服务端已经返回过空列表（源工程的 `NO_MORE`）。
  bool noMore = false;

  /// 请求进行中（源工程的 `LOADING`）。
  bool loading = false;

  /// 上一次请求失败（源工程的 `ERROR`）。
  bool hasError = false;

  bool get isEmpty => items.isEmpty;

  /// 源工程 `loadMore` 开头的短路条件：正在加载或已经到底就直接返回。
  bool get canLoadMore => !loading && !noMore && !hasError;

  /// 追加一页数据。空页 → [noMore]，否则页码前进。
  ///
  /// 返回本页真实新增的条目数，和源工程 `items.addAll(data)` 后的效果一致。
  int append(List<T> pageItems) {
    loading = false;
    hasError = false;
    if (pageItems.isEmpty) {
      noMore = true;
      return 0;
    }
    items.addAll(pageItems);
    page += 1;
    return pageItems.length;
  }

  /// 记录一次失败（源工程的 `catchError` → `ERROR`）。
  void fail() {
    loading = false;
    hasError = true;
  }

  /// 源工程 `refresh()`：清空列表并把页码拨回 1。
  void reset() {
    items.clear();
    page = 1;
    noMore = false;
    loading = false;
    hasError = false;
  }
}
