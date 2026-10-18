import 'package:dashboard/features/live/my_tv/my_tv_cache_entry.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_guide.dart';
import 'package:dashboard/features/live/my_tv/my_tv_epg_parser.dart';
import 'package:dashboard/features/live/my_tv/my_tv_ttl_cache.dart';
import 'package:http/http.dart' as http;

/// Fetches and parses XMLTV, caching the raw document per calendar day.
///
/// Mirrors the source app: a cached document from today is reused; on a new day
/// nothing is refreshed before [refreshHour] because the upstream EPG has not
/// been regenerated yet.
class MyTvEpgRepository {
  MyTvEpgRepository({
    required this.fetchXml,
    required this.read,
    required this.write,
    this.parser = const MyTvEpgParser(),
    DateTime Function()? now,
    this.refreshHour = 6,
  }) : _now = now ?? DateTime.now;

  /// Production repository backed by HTTP and [SharedPreferences].
  factory MyTvEpgRepository.production({
    http.Client? client,
    DateTime Function()? now,
  }) {
    final httpClient = client ?? http.Client();
    final cache = MyTvTtlCache.preferences(key: 'my_tv_epg', now: now);
    return MyTvEpgRepository(
      read: cache.read,
      write: cache.write,
      now: now,
      fetchXml: () async {
        final response = await httpClient
            .get(Uri.parse(defaultXml))
            .timeout(const Duration(seconds: 20));
        if (response.statusCode != 200) {
          throw Exception('EPG 请求失败：HTTP ${response.statusCode}');
        }
        return response.body;
      },
    );
  }

  static const defaultXml = 'https://live.fanmingming.com/e.xml';

  final Future<String> Function() fetchXml;
  final MyTvCacheRead read;
  final MyTvCacheWrite write;
  final MyTvEpgParser parser;
  final DateTime Function() _now;

  /// Local hour before which a new day's EPG is considered unavailable.
  final int refreshHour;

  Future<MyTvEpgGuide> load({Set<String> channels = const {}}) async {
    final now = _now();
    final entry = await read();
    if (entry != null && _sameDay(entry.savedAt, now)) {
      return MyTvEpgGuide(parser.parse(entry.content, channels: channels));
    }
    if (now.hour < refreshHour) return const MyTvEpgGuide.empty();
    final xml = await fetchXml();
    await write(MyTvCacheEntry(content: xml, savedAt: now));
    return MyTvEpgGuide(parser.parse(xml, channels: channels));
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
