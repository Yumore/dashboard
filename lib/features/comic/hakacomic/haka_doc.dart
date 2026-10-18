import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// Comic document used by every paged list
/// (`haka_comic/lib/network/models.dart:205-267`).
class HakaDoc extends HakaComicBase {
  const HakaDoc({
    required this.uid,
    required this.title,
    required this.author,
    required this.totalViews,
    required this.totalLikes,
    required this.pagesCount,
    required this.epsCount,
    required this.finished,
    required this.categories,
    required this.thumb,
    required this.id,
    required this.likesCount,
    required this.tags,
  });

  @override
  final String uid;

  @override
  final String title;

  @override
  final String author;

  @override
  final int? totalViews;

  @override
  final int? totalLikes;

  final int pagesCount;

  final int epsCount;

  @override
  final bool finished;

  @override
  final List<String> categories;

  @override
  final HakaImageDetail thumb;

  final String? id;

  @override
  final int likesCount;

  @override
  final List<String> tags;

  factory HakaDoc.fromJson(Map<String, dynamic> json) {
    return HakaDoc(
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
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': uid,
    'title': title,
    'author': author,
    'totalViews': totalViews,
    'totalLikes': totalLikes,
    'pagesCount': pagesCount,
    'epsCount': epsCount,
    'finished': finished,
    'categories': categories,
    'thumb': thumb.toJson(),
    'id': id,
    'likesCount': likesCount,
    'tags': tags,
  };
}
