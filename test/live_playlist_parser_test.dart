import 'package:dashboard/features/live/live_playlist_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M3U subscription groups channels and merges backup URLs', () {
    const source = '''#EXTM3U
#EXTINF:-1 tvg-id="news" group-title="新闻",新闻台
https://example.com/news.m3u8
#EXTINF:-1 tvg-id="news" group-title="新闻",新闻台
https://backup.example.com/news.m3u8
''';
    final channels = const LivePlaylistParser().parse(source);
    expect(channels, hasLength(1));
    expect(channels.single.group, '新闻');
    expect(channels.single.urls, hasLength(2));
  });

  test('TXT subscription uses genre markers', () {
    const source = '''娱乐,#genre#
电影台,https://example.com/movie.m3u8
''';
    final channels = const LivePlaylistParser().parse(source);
    expect(channels.single.name, '电影台');
    expect(channels.single.group, '娱乐');
  });
}
