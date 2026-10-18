import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_home_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:flutter/foundation.dart';

/// 源 `HomeFeedData`。
typedef FeedbooksHomeFeedData = ({
  FeedbooksCategoryFeed popularFeed,
  FeedbooksCategoryFeed recentFeed,
});

/// 源 `HomeFeedNotifier`（riverpod）→ 宿主 `ChangeNotifier`。
///
/// 失败语义照抄：两个 feed 任意一个为空就抛对应 failure 的 `description`
/// （源里 `throw failure!.description`，抛的是字符串）。
class FeedbooksHomeFeedController extends ChangeNotifier {
  FeedbooksHomeFeedController({required FeedbooksHomeRepository repository})
    : _repository = repository;

  final FeedbooksHomeRepository _repository;

  FeedbooksHomeFeedData? _data;
  String? _error;
  bool _loading = false;

  FeedbooksHomeFeedData? get data => _data;
  String? get error => _error;
  bool get loading => _loading;

  /// 源 `fetch()`：先 loading，再整体刷新（首页下拉刷新走的也是它）。
  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _fetch();
    } catch (error) {
      _error = error.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<FeedbooksHomeFeedData> _fetch() async {
    final FeedbooksRepositoryData popular = await _repository
        .getPopularHomeFeed();
    final FeedbooksRepositoryData recent = await _repository.getRecentHomeFeed();
    final FeedbooksCategoryFeed? popularFeed = popular.feed;
    final FeedbooksCategoryFeed? recentFeed = recent.feed;
    if (popularFeed == null) {
      throw popular.failure!.description;
    }
    if (recentFeed == null) {
      throw recent.failure!.description;
    }
    return (popularFeed: popularFeed, recentFeed: recentFeed);
  }
}
