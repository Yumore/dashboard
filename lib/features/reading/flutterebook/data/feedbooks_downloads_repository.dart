/// 源工程 `DownloadsRepository`。
abstract class FeedbooksDownloadsRepository {
  Future<void> addBook(Map<String, dynamic> book, String id);

  Future<void> deleteBook(String id);

  Future<void> deleteAllBooksWithId(String id);

  Future<List<Map<String, dynamic>>> downloadList();

  Future<Map<String, dynamic>?> fetchBook(String id);

  Future<Stream<List<Map<String, dynamic>>>> downloadListStream();

  Future<void> clearBooks();
}
