import 'package:dashboard/features/live/my_tv/my_tv_group.dart';
import 'package:dashboard/features/live/my_tv/my_tv_playlist_parser.dart';
import 'package:dashboard/features/live/my_tv/my_tv_ttl_cache.dart';
import 'package:http/http.dart' as http;

/// Loads a playlist, using a 24h cache for the default public source.
class MyTvPlaylistRepository {
  MyTvPlaylistRepository({
    required Future<String> Function(Uri source) fetch,
    MyTvTtlCache? cache,
    MyTvPlaylistParser parser = const MyTvPlaylistParser(),
  }) : _fetch = fetch,
       _cache = cache,
       _parser = parser;

  /// Production repository backed by HTTP and [SharedPreferences].
  factory MyTvPlaylistRepository.production({
    http.Client? client,
    MyTvTtlCache? cache,
  }) {
    final httpClient = client ?? http.Client();
    return MyTvPlaylistRepository(
      cache: cache ?? MyTvTtlCache.preferences(key: 'my_tv_playlist'),
      fetch: (source) async {
        final response = await httpClient
            .get(source)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) {
          throw Exception('直播源请求失败：HTTP ${response.statusCode}');
        }
        return response.body;
      },
    );
  }

  /// Public IPTV playlist used by the source app (ghproxy mirror).
  static const defaultSource =
      'https://mirror.ghproxy.com/https://raw.githubusercontent.com/zhumeng11/IPTV/main/IPTV.m3u';

  final Future<String> Function(Uri source) _fetch;
  final MyTvTtlCache? _cache;
  final MyTvPlaylistParser _parser;

  /// Fetches and parses [source], defaulting to [defaultSource].
  ///
  /// Only the default source is cached: a one-off custom URL must not
  /// overwrite (or be served from) the shared 24h cache slot.
  Future<List<MyTvGroup>> load({Uri? source, bool simplify = false}) async {
    final uri = source ?? Uri.parse(defaultSource);
    final useCache = source == null;
    if (useCache) {
      final cached = await _cache?.get();
      if (cached != null) return _parser.parse(cached, simplify: simplify);
    }
    final body = await _fetch(uri);
    if (useCache) await _cache?.put(body);
    return _parser.parse(body, simplify: simplify);
  }

  /// Re-parses already-fetched [source] (e.g. after toggling simplification).
  List<MyTvGroup> parse(String source, {bool simplify = false}) =>
      _parser.parse(source, simplify: simplify);
}
