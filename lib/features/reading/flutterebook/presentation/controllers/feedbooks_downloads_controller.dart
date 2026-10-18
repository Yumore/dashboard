import 'dart:async';

import 'package:dashboard/features/reading/flutterebook/data/feedbooks_download_record.dart';
import 'package:dashboard/features/reading/flutterebook/data/feedbooks_downloads_repository.dart';
import 'package:flutter/foundation.dart';

/// 源 `DownloadsNotifier`（riverpod）→ 宿主 `ChangeNotifier`。
///
/// 与源一致：构造后先取一次全量列表，再订阅本地数据源的变更流；每条变更
/// 直接覆盖列表（源里是 `state = AsyncValue.data(downloads)`）。
class FeedbooksDownloadsController extends ChangeNotifier {
  FeedbooksDownloadsController({required FeedbooksDownloadsRepository repository})
    : _repository = repository;

  final FeedbooksDownloadsRepository _repository;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  List<FeedbooksDownloadRecord> _records = const <FeedbooksDownloadRecord>[];

  List<FeedbooksDownloadRecord> get records => _records;

  /// 源 `build()`：拉全量 + `_listen()`。
  Future<void> load() async {
    _records = (await _repository.downloadList())
        .map(FeedbooksDownloadRecord.fromMap)
        .toList(growable: false);
    notifyListeners();
    await _listen();
  }

  Future<void> _listen() async {
    await _subscription?.cancel();
    _subscription = (await _repository.downloadListStream()).listen(
      (List<Map<String, dynamic>> downloads) {
        _records = downloads
            .map(FeedbooksDownloadRecord.fromMap)
            .toList(growable: false);
        notifyListeners();
      },
    );
  }

  /// 源 `fetchBook(id)`：只查单条，UI 用它判断是否已下载。
  Future<FeedbooksDownloadRecord?> fetchBook(String id) async {
    final Map<String, dynamic>? book = await _repository.fetchBook(id);
    return book == null ? null : FeedbooksDownloadRecord.fromMap(book);
  }

  /// 源 `addBook(book, id)`。
  Future<void> addBook(FeedbooksDownloadRecord book, String id) =>
      _repository.addBook(book.toMap(), id);

  Future<void> deleteBook(String id) => _repository.deleteBook(id);

  Future<void> clearBooks() => _repository.clearBooks();

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
