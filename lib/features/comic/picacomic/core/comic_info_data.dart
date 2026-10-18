import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/history_mixin.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';

/// Ports PicaComic's `ComicInfoData` (detail payload for every source).
class ComicInfoData with HistoryMixin {
  @override
  final String title;

  @override
  final String? subTitle;

  @override
  final String cover;

  final String? description;

  /// Grouped tags, e.g. `{"作者": ["..."]}`.
  final Map<String, List<String>> tags;

  /// Chapter id -> chapter name; `null` for single-chapter comics.
  final Map<String, String>? chapters;

  final List<String>? thumbnails;

  final Future<Res<List<String>>> Function(String id, int page)?
  thumbnailLoader;

  final int thumbnailMaxPage;

  final List<BaseComic>? suggestions;

  final String sourceKey;

  final String comicId;

  final bool? isFavorite;

  final String? subId;

  const ComicInfoData(
    this.title,
    this.subTitle,
    this.cover,
    this.description,
    this.tags,
    this.chapters,
    this.thumbnails,
    this.thumbnailLoader,
    this.thumbnailMaxPage,
    this.suggestions,
    this.sourceKey,
    this.comicId, {
    this.isFavorite,
    this.subId,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'subTitle': subTitle,
    'cover': cover,
    'description': description,
    'tags': tags,
    'chapters': chapters,
    'sourceKey': sourceKey,
    'comicId': comicId,
    'isFavorite': isFavorite,
    'subId': subId,
  };

  ComicInfoData.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String,
      subTitle = json['subTitle'] as String?,
      cover = json['cover'] as String,
      description = json['description'] as String?,
      tags = _generateMap(json['tags'] as Map),
      chapters = json['chapters'] == null
          ? null
          : Map<String, String>.from(json['chapters'] as Map),
      thumbnails = null,
      thumbnailLoader = null,
      thumbnailMaxPage = 0,
      suggestions = null,
      sourceKey = json['sourceKey'] as String,
      comicId = json['comicId'] as String,
      isFavorite = json['isFavorite'] as bool?,
      subId = json['subId'] as String?;

  static Map<String, List<String>> _generateMap(Map<dynamic, dynamic> map) {
    final res = <String, List<String>>{};
    map.forEach((key, value) {
      res[key.toString()] = List<String>.from(value as List);
    });
    return res;
  }

  @override
  HistoryType get historyType => HistoryType.forSourceKey(sourceKey);

  @override
  String get target => comicId;
}
