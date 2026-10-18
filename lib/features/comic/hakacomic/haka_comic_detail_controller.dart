import 'package:flutter/foundation.dart';
import 'package:dashboard/features/comic/hakacomic/haka_chapter.dart';
import 'package:dashboard/features/comic/hakacomic/haka_comic.dart';
import 'package:dashboard/features/comic/hakacomic/haka_failure.dart';
import 'package:dashboard/features/comic/hakacomic/haka_history_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_initial.dart';
import 'package:dashboard/features/comic/hakacomic/haka_loading.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record.dart';
import 'package:dashboard/features/comic/hakacomic/haka_read_record_store.dart';
import 'package:dashboard/features/comic/hakacomic/haka_repository.dart';
import 'package:dashboard/features/comic/hakacomic/haka_request_state.dart';
import 'package:dashboard/features/comic/hakacomic/haka_success.dart';

/// Comic detail: metadata, chapter list, favourite state and resume position.
///
/// Ported from `haka_comic/lib/views/comic_details/comic_details.dart`.
class HakaComicDetailController extends ChangeNotifier {
  HakaComicDetailController({
    required this.repository,
    required this.comicId,
    required this.readRecords,
    this.history,
  });

  final HakaRepository repository;

  final String comicId;

  final HakaReadRecordStore readRecords;

  /// When supplied, opening a comic records it in local history, which is what
  /// upstream did from the detail screen.
  final HakaHistoryStore? history;

  HakaRequestState<HakaComic> _state = const HakaInitial<HakaComic>();

  List<HakaChapter> _chapters = const [];

  HakaReadRecord? _record;

  bool _favourite = false;

  bool _togglingFavourite = false;

  Object? _chaptersError;

  bool _disposed = false;

  HakaRequestState<HakaComic> get state => _state;

  /// Chapters in the order the server returned them.
  List<HakaChapter> get chapters => List.unmodifiable(_chapters);

  /// Chapters ascending by `order`, used for reader navigation.
  List<HakaChapter> get orderedChapters {
    final sorted = [..._chapters]..sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(sorted);
  }

  HakaReadRecord? get record => _record;

  bool get isFavourite => _favourite;

  bool get isTogglingFavourite => _togglingFavourite;

  Object? get chaptersError => _chaptersError;

  /// Chapter to resume, falling back to the first ordered chapter.
  HakaChapter? get startChapter {
    final ordered = orderedChapters;
    if (ordered.isEmpty) return null;
    final order = _record?.chapterOrder;
    if (order == null) return ordered.first;
    return ordered.firstWhere(
      (chapter) => chapter.order == order,
      orElse: () => ordered.first,
    );
  }

  /// 1-based page to resume.
  int get startPage => _record?.pageNo ?? 1;

  /// Loads detail + chapters + resume position; run once from the page state.
  Future<void> load() async {
    _state = HakaLoading<HakaComic>(_state.data);
    _notify();
    try {
      final comic = await repository.fetchComicDetails(comicId);
      _favourite = comic.isFavourite;
      _state = HakaSuccess<HakaComic>(comic);
      await history?.insert(comicId, comic.toJson());
    } catch (error) {
      _state = HakaFailure<HakaComic>(error);
      _notify();
      return;
    }
    _notify();
    await loadChapters();
    await refreshRecord();
  }

  /// A chapter-list failure is non-fatal: the detail stays usable.
  Future<void> loadChapters() async {
    _chaptersError = null;
    try {
      _chapters = await repository.fetchChapters(comicId);
    } catch (error) {
      _chaptersError = error;
    }
    _notify();
  }

  Future<void> refreshRecord() async {
    _record = await readRecords.get(comicId);
    _notify();
  }

  /// `POST comics/{id}/favourite`; the server-reported action wins.
  Future<String?> toggleFavourite() async {
    if (_togglingFavourite) return null;
    _togglingFavourite = true;
    _notify();
    String? action;
    try {
      action = await repository.favoriteComic(comicId);
      if (action == 'favourite') {
        _favourite = true;
      } else if (action == 'unfavourite') {
        _favourite = false;
      }
    } catch (_) {
      action = null;
    }
    _togglingFavourite = false;
    _notify();
    return action;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}
