import 'package:dashboard/features/comic/hakacomic/haka_doc.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// Comic row persisted by the history / local-favourites stores
/// (`haka_comic/lib/network/models.dart:1083-1109`).
class HakaHistoryDoc extends HakaDoc {
  const HakaHistoryDoc({
    required super.uid,
    required super.title,
    required super.author,
    required super.totalViews,
    required super.totalLikes,
    required super.pagesCount,
    required super.epsCount,
    required super.finished,
    required super.categories,
    required super.thumb,
    required super.id,
    required super.likesCount,
    required super.tags,
    required this.updatedAt,
    required this.createdAt,
  });

  final String updatedAt;

  final String createdAt;

  factory HakaHistoryDoc.fromJson(Map<String, dynamic> json) {
    return HakaHistoryDoc(
      uid: json['_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      totalViews: json['totalViews'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int?,
      pagesCount: json['pagesCount'] as int,
      epsCount: json['epsCount'] as int,
      finished: json['finished'] as bool,
      categories: hakaStringList(json['categories']),
      thumb: HakaImageDetail.fromJson(json['thumb'] as Map<String, dynamic>),
      id: json['id'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      tags: hakaStringList(json['tags']),
      updatedAt: json['updatedAt'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  /// Row-shaped map used by both stores.
  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'updatedAt': updatedAt,
    'createdAt': createdAt,
  };
}
