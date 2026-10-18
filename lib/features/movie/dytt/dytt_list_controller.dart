import 'package:dashboard/features/movie/dytt/dytt_api.dart';
import 'package:dashboard/features/movie/dytt/dytt_error_message.dart';
import 'package:dashboard/features/movie/dytt/dytt_movie_detail.dart';
import 'package:flutter/foundation.dart';

/// 分类列表 / 搜索结果的分页控制器。
///
/// 源工程的 `ListPageState` 只请求第 1 页、下拉刷新时重取；`page` 参数
/// 在源站已存在但没有被使用。这里保留第 1 页的请求形态，并补上滚动加载：
/// 直到服务端返回空页才认为没有更多——源站没有返回总页数，无法更早判断。
class DyttListController extends ChangeNotifier {
  DyttListController({
    required this.api,
    required this.categoryId,
    this.searchContent = '',
  });

  final DyttApi api;

  /// 源工程 `getCategoryIdByTab()` 的映射结果，见 `DyttCategory`。
  final int categoryId;

  /// 列表页恒为空串；搜索页传关键词。
  final String searchContent;

  final List<DyttMovieDetail> _items = <DyttMovieDetail>[];
  int _page = 0;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  String? _moreError;
  bool _disposed = false;

  List<DyttMovieDetail> get items => List<DyttMovieDetail>.unmodifiable(_items);

  /// 已成功加载的页码，0 表示尚未加载。
  int get page => _page;

  bool get isLoading => _loading;

  bool get isLoadingMore => _loadingMore;

  bool get hasMore => _hasMore;

  /// 首屏错误；页面展示后可重试。
  String? get error => _error;

  /// 加载下一页的错误；已加载的条目仍然保留。
  String? get moreError => _moreError;

  /// 加载（或刷新）第 1 页。重复调用会被忽略。
  Future<void> load({bool refresh = false}) async {
    if (_loading || _disposed) return;
    if (refresh) {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _moreError = null;
    }
    _loading = true;
    _error = null;
    _notify();
    try {
      final result = await api.movieList(
        categoryId: categoryId,
        page: 1,
        searchContent: searchContent,
      );
      if (_disposed) return;
      _items
        ..clear()
        ..addAll(result);
      _page = 1;
      _hasMore = result.isNotEmpty;
    } catch (error) {
      if (!_disposed) _error = dyttErrorMessage(error);
    } finally {
      if (!_disposed) {
        _loading = false;
        _notify();
      }
    }
  }

  /// 追加下一页；尚未加载第 1 页、没有更多、正在加载或已释放时是空操作。
  Future<void> loadMore() async {
    if (_disposed || _loading || _loadingMore || !_hasMore || _page == 0) {
      return;
    }
    _loadingMore = true;
    _moreError = null;
    _notify();
    try {
      final nextPage = _page + 1;
      final result = await api.movieList(
        categoryId: categoryId,
        page: nextPage,
        searchContent: searchContent,
      );
      if (_disposed) return;
      if (result.isEmpty) {
        _hasMore = false;
      } else {
        _page = nextPage;
        _items.addAll(result);
      }
    } catch (error) {
      if (!_disposed) _moreError = dyttErrorMessage(error);
    } finally {
      if (!_disposed) {
        _loadingMore = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
