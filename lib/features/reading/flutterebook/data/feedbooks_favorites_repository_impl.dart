import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_local_data_source.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';

/// 源工程 `FavoritesRepositoryImpl`：纯转发给本地数据源。
class FeedbooksFavoritesRepositoryImpl implements FeedbooksFavoritesRepository {
  const FeedbooksFavoritesRepositoryImpl(this.localDataSource);

  final FeedbooksFavoritesLocalDataSource localDataSource;

  @override
  Future<void> addBook(FeedbooksEntry book, String id) =>
      localDataSource.addBook(book, id);

  @override
  Future<void> deleteBook(String id) => localDataSource.deleteBook(id);

  @override
  Future<Stream<List<FeedbooksEntry>>> favoritesListStream() =>
      localDataSource.favoritesListStream();

  @override
  Future<void> clearBooks() => localDataSource.clearBooks();
}
