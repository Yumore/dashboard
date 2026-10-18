import 'package:dashboard/features/reading/easymygo/entity/book_cover.dart';
import 'package:dashboard/features/reading/easymygo/library/reading_progress.dart';

/// One row of the local library.
///
/// Ported from the EasyMyGo drift rows `MangaInfo` / `NovelInfo`: the cover
/// columns (`id`, `label`, `cover`, `intro`, `jump_url`, `source`, `ext`) plus
/// the local columns `star_time`, `pin_time`, `custom_order`, `tags` and the
/// `last_read_*` history columns (see [ReadingProgress]).
///
/// [starred] / [pinned] are the port's `star_time > 0` / `pin_time > 0` test:
/// EasyMyGo's DAO exposed `watchStar()` and `watchAll()` on exactly that.
class ShelfItem {
  const ShelfItem({
    required this.cover,
    this.starred = false,
    this.pinned = false,
    this.order = 0,
    this.tags = const <String>[],
    this.progress,
    this.updatedAt = 0,
  });

  final BookCover cover;
  final bool starred;
  final bool pinned;
  final int order;
  final List<String> tags;
  final ReadingProgress? progress;
  final int updatedAt;

  String get identify => cover.identify;

  /// `last_history_time > 0` in the source app.
  bool get hasHistory => progress != null;

  ShelfItem copyWith({
    BookCover? cover,
    bool? starred,
    bool? pinned,
    int? order,
    List<String>? tags,
    ReadingProgress? progress,
    bool clearProgress = false,
    int? updatedAt,
  }) => ShelfItem(
    cover: cover ?? this.cover,
    starred: starred ?? this.starred,
    pinned: pinned ?? this.pinned,
    order: order ?? this.order,
    tags: tags ?? this.tags,
    progress: clearProgress ? null : progress ?? this.progress,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'cover': cover.toJson(),
    'starred': starred,
    'pinned': pinned,
    'order': order,
    'tags': tags,
    'progress': progress?.toJson(),
    'updated_at': updatedAt,
  };

  factory ShelfItem.fromJson(Map<String, Object?> json) => ShelfItem(
    cover: BookCover.fromJson(_map(json['cover'])),
    starred: json['starred'] as bool? ?? false,
    pinned: json['pinned'] as bool? ?? false,
    order: (json['order'] as num?)?.toInt() ?? 0,
    tags: <String>[
      for (final tag in (json['tags'] as List<Object?>? ?? const <Object?>[]))
        '$tag',
    ],
    progress: json['progress'] == null
        ? null
        : ReadingProgress.fromJson(_map(json['progress'])),
    updatedAt: (json['updated_at'] as num?)?.toInt() ?? 0,
  );

  static Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries) '${entry.key}': entry.value,
      };
    }
    return const <String, Object?>{};
  }
}
