import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';
import 'package:dashboard/features/comic/hakacomic/haka_json.dart';

/// `GET comics/{id}/recommendation` entry
/// (`haka_comic/lib/network/models.dart:503-544`).
class HakaRecommendComic {
  const HakaRecommendComic({
    required this.id,
    required this.title,
    required this.author,
    required this.thumb,
    required this.pagesCount,
    required this.epsCount,
    required this.finished,
    required this.categories,
    required this.likesCount,
  });

  final String id;

  final String title;

  final String author;

  final HakaImageDetail thumb;

  final int pagesCount;

  final int epsCount;

  final bool finished;

  final List<String> categories;

  final int likesCount;

  factory HakaRecommendComic.fromJson(Map<String, dynamic> json) {
    return HakaRecommendComic(
      id: json['_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      thumb: HakaImageDetail.fromJson(json['thumb'] as Map<String, dynamic>),
      pagesCount: json['pagesCount'] as int? ?? 0,
      epsCount: json['epsCount'] as int? ?? 0,
      finished: json['finished'] as bool,
      categories: hakaStringList(json['categories']),
      likesCount: json['likesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'author': author,
    'thumb': thumb.toJson(),
    'pagesCount': pagesCount,
    'epsCount': epsCount,
    'finished': finished,
    'categories': categories,
    'likesCount': likesCount,
  };
}
