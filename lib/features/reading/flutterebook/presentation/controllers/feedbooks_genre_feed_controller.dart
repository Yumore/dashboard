import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_explore_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:flutter/foundation.dart';

/// 源 `GenreFeedData`。
typedef FeedbooksGenreFeedData = ({
  List<FeedbooksEntry> books,
  bool loadingMore,
});

/// 源 `GenreFeedNotifier`（riverpod）→ 宿主 `ChangeNotifier`。
///
/// 翻页规则照抄：第二页起请求 `'$_url&page=$page'`，新条目 **追加** 在已有
/// 列表后面（源 `List.from(books)..addAll(...)`），期间 `loadingMore` 为 true。
class FeedbooksGenreFeedController extends ChangeNotifier {
  FeedbooksGenreFeedController({
    required FeedbooksExploreRepository repository,
    required String url,
  }) : _repository = repository,
       _url = url;

  final FeedbooksExploreRepository _repository;
  final String _url;

  FeedbooksGenreFeedData? _data;
  String? _error;

  FeedbooksGenreFeedData? get data => _data;
  String? get error => _error;
  List<FeedbooksEntry> get books => _data?.books ?? const <FeedbooksEntry>[];

  /// 源 `build(url)` / `fetch()`：重新拉第一页。
  Future<void> fetch() async {
    _error = null;
    try {
      _data = (books: await _fetch(), loadingMore: false);
    } catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  /// 源 `paginate(page)`：只在已有数据时生效。
  Future<void> paginate(int page) async {
    final FeedbooksGenreFeedData? current = _data;
    if (current == null) return;

    _data = (books: current.books, loadingMore: true);
    notifyListeners();

    try {
      final FeedbooksRepositoryData result = await _repository.getGenreFeed(
        '$_url&page=$page',
      );
      final FeedbooksCategoryFeed? feed = result.feed;
      if (feed == null) {
        throw result.failure?.description ?? '';
      }
      final List<FeedbooksEntry> books = List<FeedbooksEntry>.from(
        current.books,
      )..addAll(feed.feed?.entry ?? const <FeedbooksEntry>[]);
      _data = (books: books, loadingMore: false);
    } catch (error) {
      // 源工程在这里直接把异常抛给调用方并保持 loadingMore=true；
      // 移植版收起转圈并把错误暴露给页面，避免列表永远转圈。
      _data = (books: current.books, loadingMore: false);
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<List<FeedbooksEntry>> _fetch() async {
    final FeedbooksRepositoryData result = await _repository.getGenreFeed(_url);
    final FeedbooksCategoryFeed? feed = result.feed;
    if (feed == null) {
      throw result.failure?.description ?? '';
    }
    return feed.feed?.entry ?? const <FeedbooksEntry>[];
  }
}
