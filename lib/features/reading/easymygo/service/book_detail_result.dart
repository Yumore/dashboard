import 'package:dashboard/features/reading/easymygo/entity/book_detailed.dart';
import 'package:dashboard/features/reading/easymygo/entity/component_payload.dart';
import 'package:dashboard/features/reading/easymygo/entity/manga_chapter.dart';
import 'package:dashboard/features/reading/easymygo/entity/novel_volume.dart';

/// Result of the detail business: the book plus whichever chapter container the
/// media type uses.
///
/// EasyMyGo modelled these as two separate responses
/// (`MangaDetailedResp{detailed, chapters}` and
/// `NovelDetailedResp{detailed, volumes}`); the port merges them so the detail
/// page handles one result type.
class BookDetailResult {
  const BookDetailResult({
    required this.payload,
    this.detailed,
    this.chapters = const <MangaChapter>[],
    this.volumes = const <NovelVolume>[],
  });

  final ComponentPayload payload;
  final BookDetailed? detailed;
  final List<MangaChapter> chapters;
  final List<NovelVolume> volumes;

  bool get isError => payload.isError;

  /// Both containers empty and no detail — the source returned nothing.
  bool get isEmpty =>
      detailed == null && chapters.isEmpty && volumes.isEmpty;

  String get errorMsg => payload.errorMsg;
}
