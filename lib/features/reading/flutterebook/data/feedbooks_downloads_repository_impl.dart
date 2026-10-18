import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_local_data_source.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_repository.dart';

/// 源工程 `DownloadsRepositoryImpl`：纯转发给本地数据源。
class FeedbooksDownloadsRepositoryImpl implements FeedbooksDownloadsRepository {
  const FeedbooksDownloadsRepositoryImpl(this.localDataSource);

  final FeedbooksDownloadsLocalDataSource localDataSource;

  @override
  Future<void> addBook(Map<String, dynamic> book, String id) =>
      localDataSource.addBook(book, id);

  @override
  Future<void> deleteBook(String id) => localDataSource.deleteBook(id);

  @override
  Future<void> deleteAllBooksWithId(String id) =>
      localDataSource.deleteAllBooksWithId(id);

  @override
  Future<List<Map<String, dynamic>>> downloadList() =>
      localDataSource.downloadList();

  @override
  Future<Map<String, dynamic>?> fetchBook(String id) =>
      localDataSource.fetchBook(id);

  @override
  Future<Stream<List<Map<String, dynamic>>>> downloadListStream() =>
      localDataSource.downloadListStream();

  @override
  Future<void> clearBooks() => localDataSource.clearBooks();
}
