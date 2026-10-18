import 'package:dashboard/features/comic/hakacomic/haka_creator.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// Full comic document returned by `GET comics/{id}`
/// (`haka_comic/lib/network/models.dart:338-424`).
class HakaComic {
  const HakaComic({
    required this.id,
    required this.creator,
    required this.title,
    required this.description,
    required this.thumb,
    required this.author,
    required this.categories,
    required this.chineseTeam,
    required this.tags,
    required this.pagesCount,
    required this.epsCount,
    required this.finished,
    required this.updatedAt,
    required this.createdAt,
    required this.allowDownload,
    required this.allowComment,
    required this.totalLikes,
    required this.totalViews,
    required this.viewsCount,
    required this.likesCount,
    required this.commentsCount,
    required this.isFavourite,
    required this.isLiked,
    this.totalComments,
  });

  final String id;

  final HakaCreator creator;

  final String title;

  final String description;

  final HakaImageDetail thumb;

  final String? author;

  final List<String> categories;

  final String chineseTeam;

  final List<String> tags;

  final int pagesCount;

  final int epsCount;

  final bool finished;

  /// Wire keys keep the upstream snake case (`updated_at` / `created_at`).
  final String updatedAt;

  final String createdAt;

  final bool allowDownload;

  final bool allowComment;

  final int totalLikes;

  final int totalViews;

  final int? totalComments;

  final int viewsCount;

  final int likesCount;

  final int commentsCount;

  final bool isFavourite;

  final bool isLiked;

  factory HakaComic.fromJson(Map<String, dynamic> json) {
    return HakaComic(
      id: json['_id'] as String,
      creator: HakaCreator.fromJson(json['_creator'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      thumb: HakaImageDetail.fromJson(json['thumb'] as Map<String, dynamic>),
      author: json['author'] as String?,
      categories: hakaStringList(json['categories']),
      chineseTeam: json['chineseTeam'] as String? ?? '',
      tags: hakaStringList(json['tags']),
      pagesCount: json['pagesCount'] as int,
      epsCount: json['epsCount'] as int,
      finished: json['finished'] as bool,
      updatedAt: json['updated_at'] as String,
      createdAt: json['created_at'] as String,
      allowDownload: json['allowDownload'] as bool,
      allowComment: json['allowComment'] as bool,
      totalLikes: json['totalLikes'] as int,
      totalViews: json['totalViews'] as int,
      totalComments: json['totalComments'] as int?,
      viewsCount: json['viewsCount'] as int,
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int? ?? 0,
      isFavourite: json['isFavourite'] as bool,
      isLiked: json['isLiked'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    '_creator': creator.toJson(),
    'title': title,
    'description': description,
    'thumb': thumb.toJson(),
    'author': author,
    'categories': categories,
    'chineseTeam': chineseTeam,
    'tags': tags,
    'pagesCount': pagesCount,
    'epsCount': epsCount,
    'finished': finished,
    'updated_at': updatedAt,
    'created_at': createdAt,
    'allowDownload': allowDownload,
    'allowComment': allowComment,
    'totalLikes': totalLikes,
    'totalViews': totalViews,
    'totalComments': totalComments,
    'viewsCount': viewsCount,
    'likesCount': likesCount,
    'commentsCount': commentsCount,
    'isFavourite': isFavourite,
    'isLiked': isLiked,
  };

  HakaComic copyWith({bool? isFavourite, bool? isLiked}) {
    return HakaComic(
      id: id,
      creator: creator,
      title: title,
      description: description,
      thumb: thumb,
      author: author,
      categories: categories,
      chineseTeam: chineseTeam,
      tags: tags,
      pagesCount: pagesCount,
      epsCount: epsCount,
      finished: finished,
      updatedAt: updatedAt,
      createdAt: createdAt,
      allowDownload: allowDownload,
      allowComment: allowComment,
      totalLikes: totalLikes,
      totalViews: totalViews,
      totalComments: totalComments,
      viewsCount: viewsCount,
      likesCount: likesCount,
      commentsCount: commentsCount,
      isFavourite: isFavourite ?? this.isFavourite,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
