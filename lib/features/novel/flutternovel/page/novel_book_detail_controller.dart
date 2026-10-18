import 'dart:async';

import 'package:dashboard/features/novel/flutternovel/api/api_result.dart';
import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/models/flutter_novel_shelf_entry.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_review.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_source.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_detail_info.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_short_comment.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:flutter/foundation.dart';

/// Loads and holds everything the book intro page (详情) shows: the detail
/// payload, the source list, the chapter catalog, short comments and reviews.
///
/// Each section has its own loading flag and error slot so a failing review
/// request cannot blank the chapter list, and every request runs from an
/// explicit `load*` call — never from a widget build.
class NovelBookDetailController extends ChangeNotifier {
  NovelBookDetailController({
    required this.api,
    required this.store,
    required this.bookId,
  });

  final ZssqApi api;
  final FlutterNovelStore store;
  final String bookId;

  NovelDetailInfo? detail;
  bool detailLoading = true;
  String? detailError;

  List<NovelBookSource> sources = const <NovelBookSource>[];
  NovelBookChapter? catalog;
  bool catalogLoading = true;
  String? catalogError;

  NovelShortComment? shortComment;
  bool commentLoading = true;
  String? commentError;

  NovelBookReview? review;
  bool reviewLoading = true;
  String? reviewError;

  bool onShelf = false;

  /// Reviews current page (the API is paged by `start`/`limit`).
  int _reviewStart = 0;
  static const int reviewPageSize = 20;

  /// Fetches everything in parallel; nothing here touches the widget tree.
  Future<void> load() async {
    await Future.wait<void>(<Future<void>>[
      _loadDetail(),
      loadCatalog(),
      loadComments(),
      loadReviews(),
      refreshShelfState(),
    ]);
  }

  Future<void> _loadDetail() async {
    detailLoading = true;
    detailError = null;
    notifyListeners();
    try {
      final ApiResult<NovelDetailInfo> result = await api.getNovelDetailInfo(
        bookId,
      );
      final value = result.data;
      if (!result.isSuccess || value == null) {
        detailError = '详情加载失败';
      } else {
        detail = value;
      }
    } catch (error) {
      detailError = '$error';
    }
    detailLoading = false;
    notifyListeners();
  }

  /// Fetches the first `btoc` source and its chapter catalog.
  Future<void> loadCatalog() async {
    catalogLoading = true;
    catalogError = null;
    notifyListeners();
    try {
      final sourceResult = await api.getNovelSource(bookId);
      final list = sourceResult.data ?? const <NovelBookSource>[];
      if (!sourceResult.isSuccess || list.isEmpty) {
        catalogError = '没有可用的书源';
        catalogLoading = false;
        notifyListeners();
        return;
      }
      sources = list;
      final chapterResult = await api.getNovelCatalog(list.first.id ?? '');
      final value = chapterResult.data;
      if (!chapterResult.isSuccess || value == null) {
        catalogError = '目录加载失败';
      } else {
        catalog = value;
      }
    } catch (error) {
      catalogError = '$error';
    }
    catalogLoading = false;
    notifyListeners();
  }

  Future<void> loadComments() async {
    commentLoading = true;
    commentError = null;
    notifyListeners();
    try {
      final ApiResult<NovelShortComment> result =
          await api.getNovelShortReview(bookId);
      if (!result.isSuccess || result.data == null) {
        commentError = '短评加载失败';
      } else {
        shortComment = result.data;
      }
    } catch (error) {
      commentError = '$error';
    }
    commentLoading = false;
    notifyListeners();
  }

  Future<void> loadReviews({bool reset = true}) async {
    reviewLoading = true;
    reviewError = null;
    if (reset) {
      _reviewStart = 0;
      review = null;
    }
    notifyListeners();
    try {
      final ApiResult<NovelBookReview> result = await api.getNovelBookReview(
        bookId,
        start: _reviewStart,
        limit: reviewPageSize,
      );
      final value = result.data;
      if (!result.isSuccess || value == null) {
        reviewError = '书评加载失败';
      } else {
        review = value;
        _reviewStart += value.reviews.length;
      }
    } catch (error) {
      reviewError = '$error';
    }
    reviewLoading = false;
    notifyListeners();
  }

  Future<void> refreshShelfState() async {
    onShelf = await store.containsShelfEntry(bookId);
    notifyListeners();
  }

  /// Adds the detail payload to the shelf; requires [detail] to have loaded.
  Future<bool> addToShelf() async {
    final value = detail;
    if (value == null) return false;
    await store.saveShelfEntry(FlutterNovelShelfEntry.fromDetail(value));
    onShelf = true;
    notifyListeners();
    return true;
  }

  Future<void> removeFromShelf() async {
    await store.removeShelfEntry(bookId);
    onShelf = false;
    notifyListeners();
  }

  bool get hasMoreReviews =>
      review != null && review!.reviews.length >= reviewPageSize;
}
