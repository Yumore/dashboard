/// The source's `PagingModel<T>` (`component/lib_core/lib/model/paging_model.dart`).
///
/// Every 开眼 list payload carries `itemList` plus the absolute `nextPageUrl`
/// the paging view models feed straight back to the server.
abstract class EyepetizerPaging<T> {
  EyepetizerPaging({List<T>? itemList, this.nextPageUrl})
    : itemList = itemList ?? <T>[];

  List<T> itemList;

  /// Absolute URL of the next page, or null when the payload has no more.
  String? nextPageUrl;
}
