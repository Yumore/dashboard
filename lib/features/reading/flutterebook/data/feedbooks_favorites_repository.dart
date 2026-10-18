import 'package:dashboard/features/reading/flutterebook/models/entry.dart';

/// 源工程 `FavoritesRepository`。
abstract class FeedbooksFavoritesRepository {
  Future<void> addBook(FeedbooksEntry book, String id);

  Future<void> deleteBook(String id);

  Future<Stream<List<FeedbooksEntry>>> favoritesListStream();

  Future<void> clearBooks();
}
