import 'models/pixez_illust.dart';
import 'pixez_json.dart';

/// `GET /v1/illust/recommended` and `/v1/manga/recommended` response.
class PixezRecommendation {
  const PixezRecommendation({
    required this.illusts,
    required this.rankingIllusts,
    required this.nextUrl,
    required this.contestExists,
  });

  final List<PixezIllust> illusts;
  final List<PixezIllust> rankingIllusts;
  final String? nextUrl;
  final bool contestExists;

  bool get hasMore => nextUrl != null && nextUrl!.trim().isNotEmpty;

  factory PixezRecommendation.fromJson(Map<String, dynamic> json) {
    List<PixezIllust> parse(String key) => [
      for (final item in pixezMapList(json[key])) PixezIllust.fromJson(item),
    ];
    return PixezRecommendation(
      illusts: parse('illusts'),
      rankingIllusts: parse('ranking_illusts'),
      nextUrl: pixezStringOrNull(json['next_url']),
      contestExists: pixezBool(json['contest_exists']),
    );
  }
}
