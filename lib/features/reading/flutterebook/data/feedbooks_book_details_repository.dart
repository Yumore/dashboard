import 'package:dashboard/features/reading/flutterebook/data/feedbooks_book_repository.dart';
import 'package:dashboard/features/reading/flutterebook/feedbooks_api.dart';

/// 源工程
/// `lib/src/features/book_details/data/repositories/book_details_repository.dart`。
///
/// “More from Author” 的 feed 地址同样先抹掉 [FeedbooksApi.baseUrl]。
class FeedbooksBookDetailsRepository extends FeedbooksBookRepository {
  const FeedbooksBookDetailsRepository(super.httpClient);

  Future<FeedbooksRepositoryData> getRelatedFeed(String url) {
    final String stripedUrl = url.replaceAll(FeedbooksApi.baseUrl, '');
    return getCategory(stripedUrl);
  }
}
