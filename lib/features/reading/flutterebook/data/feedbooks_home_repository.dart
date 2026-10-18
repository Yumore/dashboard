import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';

/// 源工程 `lib/src/common/data/repositories/home/home_repository.dart`。
class FeedbooksHomeRepository extends FeedbooksBookRepository {
  const FeedbooksHomeRepository(super.httpClient);

  /// 源 `getPopularHomeFeed()`。
  Future<FeedbooksRepositoryData> getPopularHomeFeed() =>
      getCategory(FeedbooksApi.popular);

  /// 源 `getRecentHomeFeed()`。
  Future<FeedbooksRepositoryData> getRecentHomeFeed() =>
      getCategory(FeedbooksApi.recent);
}
