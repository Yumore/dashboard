import 'package:dashboard/features/reading/flutterebook/models/entry.dart';

/// 源工程 `FavoritesLocalDataSource`（sembast `favorites11.db`）。
///
/// 与下载数据源的区别：收藏存的是 `Entry.toJson()` 原始 JSON，读取时再
/// `Entry.fromJson` 还原，所以模型的 toJson/fromJson 必须成对正确。
abstract class FeedbooksFavoritesLocalDataSource {
  Future<void> addBook(FeedbooksEntry book, String id);

  Future<void> deleteBook(String id);

  Future<Stream<List<FeedbooksEntry>>> favoritesListStream();

  Future<void> clearBooks();
}
