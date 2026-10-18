import 'dart:async';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_favorites_repository.dart';
import 'package:dashboard/features/reading/flutterebook/models/entry.dart';
import 'package:flutter/foundation.dart';

/// 源 `FavoritesNotifier`（riverpod）→ 宿主 `ChangeNotifier`。
///
/// 与源一致：初始列表是空的，真实数据全部来自本地数据源的变更流
/// （源 `build()` 里 `return []` 之后由 `_listen()` 覆盖）。
class FeedbooksFavoritesController extends ChangeNotifier {
  FeedbooksFavoritesController({
    required FeedbooksFavoritesRepository repository,
  }) : _repository = repository;

  final FeedbooksFavoritesRepository _repository;

  StreamSubscription<List<FeedbooksEntry>>? _subscription;
  List<FeedbooksEntry> _favorites = const <FeedbooksEntry>[];

  List<FeedbooksEntry> get favorites => _favorites;

  Future<void> load() async {
    _favorites = const <FeedbooksEntry>[];
    notifyListeners();
    await _listen();
  }

  Future<void> _listen() async {
    await _subscription?.cancel();
    _subscription = (await _repository.favoritesListStream()).listen(
      (List<FeedbooksEntry> favorites) {
        _favorites = favorites;
        notifyListeners();
      },
    );
  }

  Future<void> addBook(FeedbooksEntry book, String id) =>
      _repository.addBook(book, id);

  Future<void> deleteBook(String id) => _repository.deleteBook(id);

  Future<void> clearBooks() => _repository.clearBooks();

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
