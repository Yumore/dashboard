import 'dart:convert';

import 'package:dashboard/features/anime/animeone/animeone_basic_parser.dart';
import 'package:dashboard/features/anime/animeone/animeone_info.dart';
import 'package:html/dom.dart';

/// 解析 animelist.json：真实响应没有表头，每行是一条动画目录信息。
class AnimeOneAnimeListParser
    implements AnimeOneBasicParser<List<AnimeOneInfo>> {
  const AnimeOneAnimeListParser();

  /// 直接解析接口返回的 JSON 文本。
  ///
  /// 站点在推广条目的名称里塞了 HTML 片段（`<a href="...">`），如果先走
  /// HTML 解析器再取文本，转义引号会被当成标签属性、连带把后面的行吞掉，
  /// 所以 JSON 接口始终按原始文本解。
  List<AnimeOneInfo> parseBody(String body) {
    final text = body.trim();
    if (text.isEmpty) return const [];
    final data = jsonDecode(text);
    if (data is! List || data.isEmpty) return const [];
    // id 为 0 的行是 anime1.pw 的推广条目，跳过。
    return data
        .whereType<List<dynamic>>()
        .where((item) => item.isNotEmpty && item.first is int && item.first > 0)
        .map(AnimeOneInfo.fromList)
        .toList();
  }

  @override
  List<AnimeOneInfo> parse(Document document) =>
      parseBody(document.body?.text ?? '');
}
