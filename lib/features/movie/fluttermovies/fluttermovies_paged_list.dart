import 'package:dashboard/features/movie/fluttermovies/fluttermovies_exception.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_result.dart';

typedef FlutterMoviesPageLoader =
    Future<FlutterMoviesListResult> Function(int page);

/// 分页列表状态（分类 / 排行 / 搜索共用），页码从 1 开始。
class FlutterMoviesPagedList {
  FlutterMoviesPagedList(this._load);

  final FlutterMoviesPageLoader _load;
  final List<FlutterMoviesListItem> items = <FlutterMoviesListItem>[];

  int _page = 0;
  int pageCount = 0;
  int total = 0;
  bool loading = false;

  /// 第一次请求是否已经结束（成功或失败），用于区分「加载中」与「空」。
  bool loadedOnce = false;
  String? error;

  int get page => _page;

  bool get isEmpty => loadedOnce && items.isEmpty && error == null;

  bool get hasMore => pageCount > 0 && _page < pageCount;

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    error = null;
    try {
      final result = await _load(1);
      items
        ..clear()
        ..addAll(result.items);
      _page = 1;
      pageCount = result.pageCount;
      total = result.total;
    } catch (exception) {
      error = _messageOf(exception);
      items.clear();
      _page = 0;
      pageCount = 0;
      total = 0;
    } finally {
      loadedOnce = true;
      loading = false;
    }
  }

  Future<void> loadMore() async {
    if (loading || !hasMore) return;
    loading = true;
    error = null;
    final next = _page + 1;
    try {
      final result = await _load(next);
      items.addAll(result.items);
      _page = next;
      pageCount = result.pageCount;
      total = result.total;
    } catch (exception) {
      error = _messageOf(exception);
    } finally {
      loading = false;
    }
  }

  static String _messageOf(Object exception) =>
      exception is FlutterMoviesException ? exception.message : '$exception';
}
