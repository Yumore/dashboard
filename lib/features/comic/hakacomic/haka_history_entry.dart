/// One comic row of the history store.
///
/// Upstream persisted the comic document plus the read record in one row
/// (`haka_comic/lib/database/history_helper.dart:48-63`); this port keeps the
/// document and the timestamp.
class HakaHistoryEntry {
  const HakaHistoryEntry({required this.comicId, required this.doc, required this.createdAt});

  final String comicId;

  /// Raw comic document, stored verbatim so unknown fields survive.
  final Map<String, dynamic> doc;

  /// Unix milliseconds; rows are returned most-recent-first.
  final int createdAt;

  Map<String, dynamic> toJson() => {
    'comic_id': comicId,
    'doc': doc,
    'created_at': createdAt,
  };

  factory HakaHistoryEntry.fromJson(Map<String, dynamic> json) {
    return HakaHistoryEntry(
      comicId: json['comic_id'] as String,
      doc: Map<String, dynamic>.from(json['doc'] as Map),
      createdAt: json['created_at'] as int,
    );
  }
}
