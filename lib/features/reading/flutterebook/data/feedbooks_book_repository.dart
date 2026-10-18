import 'package:dashboard/features/reading/flutterebook/data/feedbooks_gdata_converter.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_http_failure.dart';
import 'package:dashboard/features/reading/flutterebook/models/category_feed.dart';
import 'package:dio/dio.dart';

/// 源工程 `BookRepositoryData`：feed 与 failure 只会有一个非空。
typedef FeedbooksRepositoryData = ({
  FeedbooksCategoryFeed? feed,
  FeedbooksHttpFailure? failure,
});

/// 源工程 `lib/src/common/data/repositories/book/book_repository.dart`。
///
/// 只区分 404 与“其它”，404 之外的 DioException（含超时、断网）都算
/// [FeedbooksHttpFailure.unknown]；`statusCode` 取不到时按 500 处理。
abstract class FeedbooksBookRepository {
  const FeedbooksBookRepository(this.httpClient);

  final Dio httpClient;

  Future<FeedbooksRepositoryData> getCategory(String url) async {
    try {
      final Response<dynamic> response = await httpClient.get<dynamic>(url);
      final FeedbooksCategoryFeed category = FeedbooksGdataConverter()
          .toCategoryFeed(response.data.toString());
      return (feed: category, failure: null);
    } on DioException catch (error) {
      final int statusCode = error.response?.statusCode ?? 500;
      if (statusCode == 404) {
        return (feed: null, failure: FeedbooksHttpFailure.notFound);
      }
      return (feed: null, failure: FeedbooksHttpFailure.unknown);
    }
  }
}
