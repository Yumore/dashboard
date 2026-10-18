import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_page.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_result.dart';

/// Parses a `search` InnerTube response.
///
/// The response shape changes frequently, so the parser walks the tree looking
/// for `videoRenderer` nodes and the first continuation token. Live streams are
/// filtered out, matching the source app's search service.
class YoutubeDlSearchParser {
  const YoutubeDlSearchParser();

  YoutubeDlSearchPage parse(Map<String, dynamic> json) {
    final items = <YoutubeDlSearchResult>[];
    var continuation = '';
    _walk(json, (key, value) {
      if (key == 'videoRenderer') {
        final item = YoutubeDlSearchResult.fromRenderer(value);
        if (item.videoId.isNotEmpty && !item.isLive) items.add(item);
      } else if (key == 'continuationCommand' && continuation.isEmpty) {
        final token = YoutubeDlJson.asString(value['token']);
        if (token.isNotEmpty) continuation = token;
      }
    });
    return YoutubeDlSearchPage(
      items: List<YoutubeDlSearchResult>.unmodifiable(items),
      continuation: continuation,
    );
  }

  void _walk(
    Object? node,
    void Function(String key, Map<String, dynamic> value) visit,
  ) {
    if (node is List) {
      for (final child in node) {
        _walk(child, visit);
      }
      return;
    }
    if (node is! Map) return;
    final map = YoutubeDlJson.asMap(node);
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is Map) {
        final child = YoutubeDlJson.asMap(value);
        visit(entry.key, child);
        _walk(child, visit);
      } else if (value is List) {
        _walk(value, visit);
      }
    }
  }
}
