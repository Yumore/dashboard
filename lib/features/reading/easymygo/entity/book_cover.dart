import 'package:dashboard/features/reading/easymygo/entity/book_summary.dart';
import 'package:dashboard/features/reading/easymygo/entity/source_type.dart';

/// Ported from `lib/entity/book/cover/book_cover.dart` (EasyMyGo).
///
/// The original merged the identical `MangaCover` and `NovelCover` shapes into
/// this one entity via `fromMangaCover` / `fromNovelCover`; the port keeps the
/// merged entity and its `type` discriminator.
class BookCover {
  const BookCover({
    required this.type,
    required this.id,
    required this.label,
    required this.cover,
    required this.intro,
    required this.jumpUrl,
    required this.source,
    this.ext = '',
  });

  final SourceType type;
  final String id;
  final String label;
  final String cover;
  final String intro;
  final String jumpUrl;
  final String source;
  final String ext;

  String get identify => '$id-|-$source';

  BookSummary get summary => BookSummary(source: source, id: id, ext: ext);

  Map<String, Object?> toJson() => <String, Object?>{
    'type': type.name,
    'id': id,
    'label': label,
    'cover': cover,
    'intro': intro,
    'jump_url': jumpUrl,
    'source': source,
    'ext': ext,
  };

  factory BookCover.fromJson(Map<String, Object?> json) => BookCover(
    type: SourceType.fromName('${json['type'] ?? ''}'),
    id: '${json['id'] ?? ''}',
    label: '${json['label'] ?? ''}',
    cover: '${json['cover'] ?? ''}',
    intro: '${json['intro'] ?? ''}',
    jumpUrl: '${json['jump_url'] ?? json['jumpUrl'] ?? ''}',
    source: '${json['source'] ?? ''}',
    ext: '${json['ext'] ?? ''}',
  );
}
