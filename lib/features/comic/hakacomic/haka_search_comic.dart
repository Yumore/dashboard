import 'package:dashboard/features/comic/hakacomic/haka_comic_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// Search hit (`haka_comic/lib/network/models.dart:783-861`).
///
/// Two fields need the lenient converters the upstream generator emitted:
/// `likesCount` (sometimes a String) and `totalLikes` (sometimes a String).
class HakaSearchComic extends HakaComicBase {
  const HakaSearchComic({
    required this.updatedAt,
    required this.thumb,
    required this.author,
    required this.description,
    required this.chineseTeam,
    required this.createdAt,
    required this.finished,
    required this.totalViews,
    required this.categories,
    required this.totalLikes,
    required this.title,
    required this.tags,
    required this.uid,
    required this.likesCount,
  });

  final String updatedAt;

  @override
  final HakaImageDetail thumb;

  @override
  final String author;

  final String? description;

  final String? chineseTeam;

  final String createdAt;

  @override
  final bool finished;

  @override
  final int? totalViews;

  @override
  final List<String> categories;

  @override
  final int? totalLikes;

  @override
  final String title;

  @override
  final List<String> tags;

  @override
  final String uid;

  @override
  final int likesCount;

  /// `int` passthrough, `String` parsed, anything else `0`
  /// (`models.dart:828-832`).
  static int likesCountFromJson(Object? value) {
    final parsed = hakaIntOrNull(value);
    return parsed ?? 0;
  }

  /// Same tolerance but keeps `null` when unparseable
  /// (`models.dart:834-838`).
  static int? totalLikesFromJson(Object? value) => hakaIntOrNull(value);

  factory HakaSearchComic.fromJson(Map<String, dynamic> json) {
    return HakaSearchComic(
      updatedAt: json['updated_at'] as String,
      thumb: HakaImageDetail.fromJson(json['thumb'] as Map<String, dynamic>),
      author: json['author'] as String? ?? '??',
      description: json['description'] as String?,
      chineseTeam: json['chineseTeam'] as String?,
      createdAt: json['created_at'] as String,
      finished: json['finished'] as bool,
      totalViews: json['totalViews'] as int?,
      categories: hakaStringList(json['categories']),
      totalLikes: totalLikesFromJson(json['totalLikes']),
      title: json['title'] as String,
      tags: hakaStringList(json['tags']),
      uid: json['_id'] as String,
      likesCount: likesCountFromJson(json['likesCount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'updated_at': updatedAt,
    'thumb': thumb.toJson(),
    'author': author,
    'description': description,
    'chineseTeam': chineseTeam,
    'created_at': createdAt,
    'finished': finished,
    'totalViews': totalViews,
    'categories': categories,
    'totalLikes': totalLikes,
    'title': title,
    'tags': tags,
    '_id': uid,
    'likesCount': likesCount,
  };
}
