import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_details_repository.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_http_failure.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:flutter/foundation.dart';

/// 源 `BookDetailsNotifier`（riverpod）→ 宿主 `ChangeNotifier`。
///
/// 失败判断照抄源工程：`if (failure is HttpFailure) throw
/// failure.description;`——也就是说 feed 为空但 failure 为 null 时会
/// `success!` 空断言崩溃（源里不会发生，两个字段互斥）。
class FeedbooksBookDetailsController extends ChangeNotifier {
  FeedbooksBookDetailsController({
    required FeedbooksBookDetailsRepository repository,
    required String url,
  }) : _repository = repository,
       _url = url;

  final FeedbooksBookDetailsRepository _repository;
  final String _url;

  FeedbooksCategoryFeed? _feed;
  String? _error;

  FeedbooksCategoryFeed? get feed => _feed;
  String? get error => _error;

  Future<void> fetch() async {
    _error = null;
    try {
      _feed = await _fetch();
    } catch (error) {
      _error = error.toString();
    }
    notifyListeners();
  }

  Future<FeedbooksCategoryFeed> _fetch() async {
    final FeedbooksRepositoryData result = await _repository.getRelatedFeed(
      _url,
    );
    final FeedbooksCategoryFeed? success = result.feed;
    final FeedbooksHttpFailure? failure = result.failure;
    if (failure is FeedbooksHttpFailure) {
      throw failure.description;
    }
    return success!;
  }
}
