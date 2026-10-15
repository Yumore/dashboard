import 'dart:convert';

import 'package:dashboard/features/anime/anime_episode_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'resolves encoded iframe, relative API, HD/SD mirrors and episode links',
    () async {
      final encoded = '<iframe src="/embed/player">'.codeUnits
          .map((code) => '"${base64Encode(utf8.encode('char${code + 17}'))}"')
          .join(',');
      final requests = <Uri>[];
      final resolver = AnimeEpisodeResolver(
        client: MockClient((request) async {
          requests.add(request.url);
          switch (request.url.path) {
            case '/episode-2':
              return http.Response('''
            <div class="ilxbaslik8"><h1><a>Episode 2</a></h1></div>
            <a rel="prev" href="/episode-1">Previous</a>
            <a rel="next" href="/episode-3">Next</a>
            <table><tr><td class="larkax">[$encoded]; parseInt(atob(value)) - 17</td></tr></table>
          ''', 200);
            case '/embed/player':
              return http.Response('get("../video.json")', 200);
            case '/video.json':
              expect(
                request.headers['Referer'],
                'https://anime.test/episode-2',
              );
              expect(request.headers['x-requested-with'], 'XMLHttpRequest');
              return http.Response(
                jsonEncode({
                  'server': 'https://stream.test',
                  'cdn': 'https://mirror.test',
                  'hd': 'id+&high',
                  'enc': 'id/low',
                }),
                200,
              );
            default:
              return http.Response('Unexpected request', 404);
          }
        }),
      );
      addTearDown(resolver.dispose);
      final playback = await resolver.resolve(
        Uri.parse('https://anime.test/episode-2'),
      );
      expect(playback.title, 'Episode 2');
      expect(playback.previous.toString(), 'https://anime.test/episode-1');
      expect(playback.next.toString(), 'https://anime.test/episode-3');
      expect(playback.sources.length, 4);
      expect(playback.sources.first.url.queryParameters['evid'], 'id+&high');
      expect(playback.sources.last.url.host, 'mirror.test');
      expect(requests.map((uri) => uri.path), [
        '/episode-2',
        '/embed/player',
        '/video.json',
      ]);
    },
  );

  test(
    'reports missing video encoding instead of returning an empty player',
    () async {
      final resolver = AnimeEpisodeResolver(
        client: MockClient(
          (_) async => http.Response('<html>No video source</html>', 200),
        ),
      );
      addTearDown(resolver.dispose);
      await expectLater(
        resolver.resolve(Uri.parse('https://anime.test/removed')),
        throwsFormatException,
      );
    },
  );
}
