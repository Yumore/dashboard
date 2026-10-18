import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';

/// Ports PicaComic's `CustomComic` (used by the user-JS comic sources).
class CustomComic extends BaseComic {
  @override
  final String title;

  @override
  final String subTitle;

  @override
  final String cover;

  @override
  final String id;

  @override
  final List<String> tags;

  @override
  final String description;

  final String sourceKey;

  const CustomComic(
    this.title,
    this.subTitle,
    this.cover,
    this.id,
    this.tags,
    this.description,
    this.sourceKey,
  );

  CustomComic.fromJson(Map<dynamic, dynamic> json, this.sourceKey)
    : title = json['title'] as String,
      subTitle = (json['subTitle'] as String?) ?? '',
      cover = json['cover'] as String,
      id = json['id'] as String,
      tags = List<String>.from(json['tags'] as List? ?? const []),
      description = (json['description'] as String?) ?? '';
}
