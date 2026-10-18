import 'package:dashboard/features/anime/animeone/animeone_entry.dart';

/// 分类页或单集页的解析结果。
class AnimeOnePageResult {
  const AnimeOnePageResult({
    this.entries = const [],
    this.title = '',
    this.categoryLink,
  });

  final List<AnimeOneEntry> entries;

  /// 页面标题（div.page-title）。
  final String title;

  /// 分类的规范链接（div.cat-links 里的 a[href]），翻页时使用。
  final String? categoryLink;
}
