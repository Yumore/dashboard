/// 源工程 `DownloadsLocalDataSource`（sembast `download.db`，以记录 id 为主键）。
///
/// 移植版把同样的键值语义落到 shared_preferences（宿主没有 sembast），
/// 方法名与签名保持一一对应。
abstract class FeedbooksDownloadsLocalDataSource {
  /// 源 `addBook`：`record(id).put(db, book, merge: true)`。
  Future<void> addBook(Map<String, dynamic> book, String id);

  Future<void> deleteBook(String id);

  /// 源里与 [deleteBook] 完全同实现，保留这个名字以备调用方语义。
  Future<void> deleteAllBooksWithId(String id);

  Future<List<Map<String, dynamic>>> downloadList();

  Future<Map<String, dynamic>?> fetchBook(String id);

  Future<Stream<List<Map<String, dynamic>>>> downloadListStream();

  Future<void> clearBooks();
}
