import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_discover_map.dart';
import 'package:dashboard/features/reading/eso/eso_discover_pair.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';

/// 书源接口与内容类型常量（移植 eso `lib/api/api.dart` 的 `API`）。
abstract class EsoApi {
  static const int manga = 0;
  static const int novel = 1;
  static const int video = 2;
  static const int audio = 3;
  static const int rss = 4;
  static const int novelMore = 5;

  /// 当前请求地址（源实现的静态旁路，目录/正文分页时回读）。
  static String? chapterUrl;
  static String? contentUrl;

  /// 内容类型名。未知类型与源实现一致地回落到「图片」。
  static String getRuleContentTypeName(int ruleContentType) {
    switch (ruleContentType) {
      case manga:
        return '图片';
      case novel:
        return '文字';
      case video:
        return '视频';
      case audio:
        return '音频';
      case rss:
        return 'RSS';
      case novelMore:
        return '图文';
      default:
        return '图片';
    }
  }

  /// 内容类型名 → 常量，未知返回 -1。
  static int getRuleContentType(String ruleContentName) {
    switch (ruleContentName) {
      case '图片':
        return manga;
      case '文字':
        return novel;
      case '视频':
        return video;
      case '音频':
        return audio;
      case 'RSS':
        return rss;
      case '图文':
        return novelMore;
      default:
        return -1;
    }
  }

  String get origin;

  String get originTag;

  int get ruleContentType;

  Future<List<EsoSearchItem>> discover(
      Map<String, EsoDiscoverPair> params, int page, int pageSize);

  Future<List<EsoSearchItem>> search(String query, int page, int pageSize);

  Future<List<EsoChapterItem>> chapter(String url, [int? page]);

  Future<List<String>> content(String url);

  Future<List<EsoDiscoverMap>> discoverMap();
}
