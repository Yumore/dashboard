import 'package:dashboard/features/comic/hakacomic/haka_image_detail.dart';

/// Home-screen category (`haka_comic/lib/network/models.dart:110-142`).
class HakaCategory {
  const HakaCategory({
    this.id,
    required this.thumb,
    required this.title,
    required this.description,
    this.isWeb,
    this.active,
    this.link,
  });

  final String? id;

  final HakaImageDetail thumb;

  final String title;

  final String description;

  final bool? isWeb;

  final bool? active;

  final String? link;

  factory HakaCategory.fromJson(Map<String, dynamic> json) {
    return HakaCategory(
      id: json['_id'] as String?,
      thumb: HakaImageDetail.fromJson(json['thumb'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isWeb: json['isWeb'] as bool?,
      active: json['active'] as bool?,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'thumb': thumb.toJson(),
    'title': title,
    'description': description,
    'isWeb': isWeb,
    'active': active,
    'link': link,
  };
}
