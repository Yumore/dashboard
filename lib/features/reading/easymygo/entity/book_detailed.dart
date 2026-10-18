import 'package:dashboard/features/reading/easymygo/entity/book_status.dart';
import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// Ported from `MangaDetailed` / `NovelDetailed` (merged; the two shapes were
/// identical apart from the manga/novel enum types, now [BookStatus] and
/// [BookUpdateStrategy]).
class BookDetailed {
  const BookDetailed({
    required this.type,
    required this.source,
    required this.id,
    required this.label,
    required this.cover,
    required this.intro,
    required this.jumpUrl,
    this.isDetailedLoad = false,
    this.genre = '',
    this.description = '',
    this.updateStrategy = BookUpdateStrategy.always,
    this.isUpdate = false,
    this.status = BookStatus.unknown,
    this.ext = '',
  });

  final SourceType type;
  final String source;
  final String id;
  final String label;
  final String cover;
  final String intro;
  final String jumpUrl;
  final bool isDetailedLoad;
  final String genre;
  final String description;
  final BookUpdateStrategy updateStrategy;
  final bool isUpdate;
  final BookStatus status;
  final String ext;

  String get identify => '$id-|-$source';

  BookSummary get summary => BookSummary(source: source, id: id, ext: ext);
}
