import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';

/// 源工程
/// `lib/src/features/explore/data/repositories/explore_repository.dart`。
///
/// 分类页拿到的 `link.href` 是绝对地址，源工程先把 `baseURL` 前缀抹掉再交给
/// `getCategory`（Dio 的 `baseUrl` 会再拼回来），移植版保留这一步。
class FeedbooksExploreRepository extends FeedbooksBookRepository {
  const FeedbooksExploreRepository(super.httpClient);

  Future<FeedbooksRepositoryData> getGenreFeed(String url) {
    final String stripedUrl = url.replaceAll(FeedbooksApi.baseUrl, '');
    return getCategory(stripedUrl);
  }
}
