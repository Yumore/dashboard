import 'package:dashboard/features/anime/takoplay/tako_aes.dart';
import 'package:dashboard/features/anime/takoplay/tako_anime.dart';
import 'package:dashboard/features/anime/takoplay/tako_embed_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_episode.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_client.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_detail_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_endpoints.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_episode_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_search_page.dart';
import 'package:dashboard/features/anime/takoplay/tako_play_stream_resolver.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_extractor.dart';
import 'package:dashboard/features/anime/takoplay/tako_stream_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _secretKey = 'fedcba0987654321';
const _decryptKey = 'abcdef0123456789';
const _iv = '1234567890abcdef';

/// `AES-128-CBC('id=99&token=tok123&expires=1700000000', _secretKey, _iv)`
/// produced with the source algorithm; the extractor must decrypt exactly it.
const _scriptCipher =
    'HROqDk34vR8yrrXTI2bLurGj2ki0+1F7ZXJbvTTZ9Hpof03f2GJ6dWMFdAaCmZ2i';

/// `AES-128-CBC(decryptedPayload, _decryptKey, _iv)`.
const _ajaxDataCipher =
    'oTWYRyTWP8Au4Ipwc3qAZfbJsy71DQ8dv7GadF1AlUkss4lC5el8upD1Z3JcIz7U'
    'fWpEZ1f2+qfG8Z4dajoRmqX+I6+2sjAMLEAgd9VFB/C74N4X49D4ro/xNSYN1ZTga'
    '98gbG05PhiwwrcXvlAzEAy2geHFKEqorv6rt1JokwQ=';

const _decryptedPayload =
    '{"source":[{"file":"https://cdn.example.com/anime/1/1080p/index.m3u8",'
    '"label":"1080p","type":"hls"}],"type":"hls"}';

const _streamUrl = 'https://cdn.example.com/anime/1/1080p/index.m3u8';

/// `AES-128-CBC('99', _secretKey, _iv)`.
const _encryptedAnimeId = 'z3PSO2qqIdqmlOZNUz0MiA==';

const _expectedAjaxUrl =
    'https://gogoplay.io/encrypt-ajax.php?id=$_encryptedAnimeId'
    '&token=tok123&expires=1700000000&alias=99';

const _embedPage =
    '<!DOCTYPE html><html><head>'
    '<script src="https://gogoplay.io/player.js"></script>'
    '<script type="text/javascript">var player = 1;</script>'
    '<script type="text/javascript" data-encrypted="$_scriptCipher"></script>'
    '</head><body class="container-$_secretKey">'
    '<div class="wrapper container-$_iv">'
    '<div class="videocontent videocontent-$_decryptKey">'
    '<input type="hidden" value="99">'
    '</div></div></body></html>';

const _searchHtml =
    '<div class="items">'
    '<div class="item">'
    '<div class="img"><a href="/anime/naruto" title="Naruto">'
    '<img src="https://cdn.example.com/naruto.jpg"></a></div>'
    '<p class="name"><a href="/anime/naruto" title="Naruto">Naruto</a></p>'
    '<p class="released">Released: 2002</p>'
    '</div>'
    '<div class="item">'
    '<div class="img"><a href="/anime/bleach" title="Bleach">'
    '<img src="https://cdn.example.com/bleach.jpg"></a></div>'
    '<p class="name"><a href="/anime/bleach" title="Bleach">Bleach</a></p>'
    '<p class="released">Released: 2004</p>'
    '</div>'
    '</div>';

const _recentHtml =
    '<div class="items">'
    '<div class="item">'
    '<div class="img"><a href="/one-piece-episode-1100">'
    '<img src="https://cdn.example.com/op.jpg"></a></div>'
    '<p class="name"><a href="/one-piece-episode-1100" title="One Piece">'
    'One Piece</a></p>'
    '<p class="episode">Episode 1100</p>'
    '</div>'
    '</div>';

const _detailHtml =
    '<div class="anime_info_body_bg">'
    '<img src="https://cdn.example.com/naruto.jpg">'
    '<h1>Naruto</h1>'
    '<p class="type">Type: TV</p>'
    '<p class="type">Plot Summary: A young ninja.</p>'
    '<p class="type">Genre: '
    '<a href="/genre/action" title="Action">Action</a>, '
    '<a href="/genre/adventure" title="Adventure">Adventure</a></p>'
    '<p class="type">Released: 2002</p>'
    '<p class="type">Status: <a href="/status/ongoing">Ongoing</a></p>'
    '</div>'
    '<div class="anime_info_episodes_next">'
    '<input type="hidden" value="1234">'
    '</div>';

const _episodeHtml =
    '<div id="episode_related"><ul>'
    '<li><a href="/naruto-episode-2"><div class="name">EP 2</div></a></li>'
    '<li><a href="/naruto-episode-1"><div class="name">EP 1</div></a></li>'
    '</ul></div>';

const _mirrorHtml =
    '<div class="mirror_link">'
    '<div class="dowload">'
    '<a href="https://cdn.example.com/naruto-1-1080p.mp4">Episode 1 1080P</a>'
    '</div>'
    '<div class="dowload">'
    '<a href="https://cdn.example.com/naruto-1-720p.mp4">Episode 1 720P</a>'
    '</div>'
    '<div class="dowload">'
    '<a href="https://cdn.example.com/naruto-1-1080p-copy.mp4">'
    'Episode 1 1080P</a></div>'
    '</div>';

const _episodePageHtml =
    '<div class="play-video">'
    '<iframe src="https://gogoplay.io/streaming.php?id=99"></iframe>'
    '</div>';

final _base = Uri.parse('https://gogoanime.wiki/');
final _anime = TakoAnime(
  title: 'Naruto',
  url: Uri.parse('https://gogoanime.wiki/anime/naruto'),
);
final _embedUri = Uri.parse('https://gogoplay.io/streaming.php?id=99');
final _episodeUri = Uri.parse('https://gogoanime.wiki/naruto-episode-1');

http.Client _mockClient({bool embedMissing = false}) {
  return MockClient((request) async {
    final url = request.url.toString();
    if (url.startsWith('https://ajax.gogocdn.net/ajax/page-recent-release')) {
      return http.Response(_recentHtml, 200);
    }
    if (url.contains('/search.html')) return http.Response(_searchHtml, 200);
    if (url.contains('encrypt-ajax.php')) {
      return http.Response('{"data":"$_ajaxDataCipher"}', 200);
    }
    if (url.contains('streaming.php')) {
      return embedMissing
          ? http.Response('gone', 404)
          : http.Response(_embedPage, 200);
    }
    if (url.contains('download')) return http.Response(_mirrorHtml, 200);
    if (url.contains('load-list-episode')) {
      return http.Response(_episodeHtml, 200);
    }
    if (url.contains('/anime/')) return http.Response(_detailHtml, 200);
    if (url.startsWith('https://gogoanime.wiki/')) {
      return http.Response(_episodePageHtml, 200);
    }
    return http.Response('missing', 404);
  });
}

void main() {
  group('TakoAes', () {
    test('encrypts the anime id with the script secret key', () {
      final cipher = TakoAes(key: _secretKey, iv: _iv);
      expect(cipher.encrypt('99'), _encryptedAnimeId);
    });

    test('decrypts the embed script cipher into ajax params', () {
      final cipher = TakoAes(key: _secretKey, iv: _iv);
      expect(
        cipher.decrypt(_scriptCipher),
        'id=99&token=tok123&expires=1700000000',
      );
    });

    test('decrypts the encrypt-ajax data field with the decrypt key', () {
      final cipher = TakoAes(key: _decryptKey, iv: _iv);
      expect(cipher.decrypt(_ajaxDataCipher), _decryptedPayload);
    });

    test('round-trips block-aligned and padded text', () {
      final cipher = TakoAes(key: _secretKey, iv: _iv);
      for (final text in ['', 'a', 'Tako-Play', 'x' * 64]) {
        expect(cipher.decrypt(cipher.encrypt(text)), text);
      }
    });

    test('rejects a wrong block size', () {
      expect(
        () => TakoAes(key: 'short', iv: _iv).encrypt('99'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => TakoAes(key: _secretKey, iv: 'short').encrypt('99'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TakoPlayEndpoints', () {
    test('builds the search url exactly as the source chopper service did', () {
      expect(
        TakoPlayEndpoints.search('naruto').toString(),
        'https://gogoanime.wiki/search.html?keyword=naruto',
      );
      expect(
        TakoPlayEndpoints.search('one piece').toString(),
        'https://gogoanime.wiki/search.html?keyword=one%20piece',
      );
    });

    test('builds catalogue and paginated genre urls', () {
      expect(
        TakoPlayEndpoints.catalogue('/popular.html').toString(),
        'https://gogoanime.wiki/popular.html',
      );
      expect(
        TakoPlayEndpoints.catalogue('anime-movies.html').toString(),
        'https://gogoanime.wiki/anime-movies.html',
      );
      expect(
        TakoPlayEndpoints.genre(
          'https://gogoanime.wiki/genre/action',
          3,
        ).toString(),
        'https://gogoanime.wiki/genre/action?page=3',
      );
    });

    test('builds the episode list url with the source ep range', () {
      expect(
        TakoPlayEndpoints.episodes('1234').toString(),
        'https://ajax.gogo-load.com/ajax/load-list-episode'
        '?ep_start=0&ep_end=5000&id=1234',
      );
    });

    test('builds the download mirror url from a streaming embed', () {
      expect(
        TakoPlayEndpoints.mirrors(_embedUri).toString(),
        'https://gogoplay.io/download?id=99',
      );
    });

    test('derives the cdn root and the encrypt-ajax request url', () {
      expect(
        TakoPlayEndpoints.cdnRoot(_embedUri.toString()).toString(),
        'https://gogoplay.io/',
      );
      expect(
        TakoPlayEndpoints.encryptedData(
          cdnRoot: TakoPlayEndpoints.cdnRoot(_embedUri.toString()),
          encryptedId: _encryptedAnimeId,
          ajaxParams: '&token=tok123&expires=1700000000',
          animeId: '99',
        ).toString(),
        _expectedAjaxUrl,
      );
      expect(
        () => TakoPlayEndpoints.cdnRoot('gogoplay.io/x'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TakoEmbedPage', () {
    test('scrapes iv, keys, script cipher and anime id by position', () {
      final page = TakoEmbedPage.parse(_embedPage);
      expect(page.iv, _iv);
      expect(page.secretKey, _secretKey);
      expect(page.decryptKey, _decryptKey);
      expect(page.scriptCipher, _scriptCipher);
      expect(page.animeId, '99');
    });

    test('fails loudly on a page without the expected markup', () {
      expect(
        () => TakoEmbedPage.parse('<html><body></body></html>'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => TakoEmbedPage.parse(
          '<div class="wrapper container-x"></div><body></body>',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TakoStreamExtractor', () {
    test('splits the decrypted params like the source', () {
      expect(
        TakoStreamExtractor.splitAjaxParams(
          'id=99&token=tok123&expires=1700000000',
        ),
        '&token=tok123&expires=1700000000',
      );
      expect(TakoStreamExtractor.splitAjaxParams('novalue'), '');
    });

    test('pulls the first file out of the decrypted source array', () {
      expect(TakoStreamExtractor.firstFileUrl(_decryptedPayload), _streamUrl);
      expect(
        TakoStreamExtractor.firstFileUrl(
          '{"source":[{"file":"https://a.test/x.mp4","label":"720p"}]}',
        ),
        'https://a.test/x.mp4',
      );
      expect(
        () => TakoStreamExtractor.firstFileUrl('{"source":[]}'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => TakoStreamExtractor.firstFileUrl('{"type":"hls"}'),
        throwsA(isA<FormatException>()),
      );
      // The source's split needs a `,` after `file:` to close the URL.
      expect(
        TakoStreamExtractor.firstFileUrl(
          '{"source":{"file":"https://a.test/x.mp4","label":"720p"}}',
        ),
        'https://a.test/x.mp4',
      );
    });

    test('runs the whole AES pipeline against a mocked network', () async {
      Uri? ajaxUri;
      Map<String, String>? ajaxHeaders;
      final client = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('encrypt-ajax.php')) {
          ajaxUri = request.url;
          ajaxHeaders = request.headers;
          return http.Response('{"data":"$_ajaxDataCipher"}', 200);
        }
        return http.Response(_embedPage, 200);
      });

      final sources = await TakoStreamExtractor(
        client: client,
      ).extract(_embedUri.toString());

      expect(ajaxUri.toString(), _expectedAjaxUrl);
      expect(ajaxHeaders?['X-Requested-With'], 'XMLHttpRequest');
      expect(sources, hasLength(1));
      expect(sources.single.url.toString(), _streamUrl);
      expect(sources.single.label, '1080p');
      expect(sources.single.type, 'hls');
      expect(sources.single.isHls, isTrue);
    });

    test(
      'falls back to a plain source when the payload shape is odd',
      () async {
        final client = MockClient((request) async {
          if (request.url.toString().contains('encrypt-ajax.php')) {
            // `source` is an object, so the label lookup cannot match.
            final payload =
                '{"source":{"file":"https://cdn.example.com/1/hd.mp4",'
                '"label":"720p"}}';
            final cipher = TakoAes(key: _decryptKey, iv: _iv);
            return http.Response('{"data":"${cipher.encrypt(payload)}"}', 200);
          }
          return http.Response(_embedPage, 200);
        });

        final sources = await TakoStreamExtractor(
          client: client,
        ).extract(_embedUri.toString());

        expect(
          sources.single.url.toString(),
          'https://cdn.example.com/1/hd.mp4',
        );
        expect(sources.single.label, '默认');
        expect(sources.single.type, 'mp4');
      },
    );

    test('throws when the embed page cannot be fetched', () async {
      final client = MockClient((_) async => http.Response('gone', 404));
      expect(
        () => TakoStreamExtractor(client: client).extract(_embedUri.toString()),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  group('TakoStreamSource', () {
    test('parses a decrypted payload entry', () {
      final source = TakoStreamSource.fromJson({
        'file': _streamUrl,
        'label': '1080p',
        'type': 'hls',
      });
      expect(source.label, '1080p');
      expect(source.url, Uri.parse(_streamUrl));
      expect(source.isHls, isTrue);
    });

    test('lists every entry and rejects payloads without sources', () {
      final sources = TakoStreamSource.listFromJson(_decryptedPayload);
      expect(sources, hasLength(1));
      expect(sources.single.url.toString(), _streamUrl);
      expect(
        () => TakoStreamSource.listFromJson('{"source":"none"}'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => TakoStreamSource.fromJson({'label': '1080p'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TakoPlayClient', () {
    test('searches and parses the result cards', () async {
      final results = await TakoPlayClient(
        client: _mockClient(),
      ).search('naruto');
      expect(results.query, 'naruto');
      expect(results.results.map((anime) => anime.title), ['Naruto', 'Bleach']);
      expect(
        results.results.first.url.toString(),
        'https://gogoanime.wiki/anime/naruto',
      );
      expect(
        results.results.first.image.toString(),
        'https://cdn.example.com/naruto.jpg',
      );
      expect(results.results.first.releasedDate, 'Released: 2002');
    });

    test('lists recently updated episodes', () async {
      final recent = await TakoPlayClient(client: _mockClient()).recent();
      expect(recent, hasLength(1));
      expect(recent.single.title, 'One Piece');
      expect(recent.single.currentEpisode, 'Episode 1100');
      expect(
        recent.single.url.toString(),
        'https://gogoanime.wiki/one-piece-episode-1100',
      );
    });

    test('loads detail and episode list in two requests', () async {
      final requested = <String>[];
      final client = MockClient((request) async {
        requested.add(request.url.toString());
        if (request.url.toString().contains('load-list-episode')) {
          return http.Response(_episodeHtml, 200);
        }
        return http.Response(_detailHtml, 200);
      });

      final details = await TakoPlayClient(
        client: client,
      ).details(_base.resolve('/anime/naruto'));

      expect(requested, hasLength(2));
      expect(
        requested.last,
        'https://ajax.gogo-load.com/ajax/load-list-episode'
        '?ep_start=0&ep_end=5000&id=1234',
      );
      expect(details.title, 'Naruto');
      expect(details.summary, 'A young ninja.');
      expect(details.status, 'Ongoing');
      expect(details.releasedDate, '2002');
      expect(details.episodeId, '1234');
      expect(details.genres.map((genre) => genre.name), [
        'Action',
        'Adventure',
      ]);
      expect(
        details.genres.first.link.toString(),
        'https://gogoanime.wiki/genre/action',
      );
      expect(details.episodes.map((episode) => episode.number), ['1', '2']);
      expect(
        details.episodes.first.link.toString(),
        'https://gogoanime.wiki/naruto-episode-1',
      );
    });

    test('reads the embed url and the download mirrors', () async {
      final client = TakoPlayClient(client: _mockClient());
      final embed = await client.embedUrl(_episodeUri);
      expect(embed.toString(), 'https://gogoplay.io/streaming.php?id=99');
      final mirrors = await client.mirrors(embed!);
      expect(mirrors.keys, ['1080P', '720P']);
      expect(
        mirrors['1080P'].toString(),
        'https://cdn.example.com/naruto-1-1080p.mp4',
      );
    });

    test('reports an http failure', () async {
      final client = TakoPlayClient(
        client: MockClient((_) async => http.Response('boom', 500)),
      );
      expect(() => client.recent(), throwsA(isA<http.ClientException>()));
    });
  });

  group('TakoPlayStreamResolver', () {
    test('resolves an episode through the AES pipeline', () async {
      final playback =
          await TakoPlayStreamResolver(
            client: TakoPlayClient(client: _mockClient()),
          ).resolve(
            TakoEpisode(number: '1', link: _episodeUri),
            title: 'Naruto 第1集',
          );

      expect(playback.title, 'Naruto 第1集');
      expect(playback.page, _episodeUri);
      expect(playback.sources.single.url.toString(), _streamUrl);
      expect(playback.sources.single.label, '1080p');
    });

    test('falls back to download mirrors when extraction dies', () async {
      final playback = await TakoPlayStreamResolver(
        client: TakoPlayClient(client: _mockClient(embedMissing: true)),
      ).resolve(TakoEpisode(number: '1', link: _episodeUri));

      expect(playback.title, '第1集');
      expect(playback.sources.map((source) => source.label), ['1080P', '720P']);
      expect(playback.sources.first.type, 'mp4');
    });
  });

  group('TakoPlaySearchPage', () {
    testWidgets('lists recent episodes and searches', (tester) async {
      final client = TakoPlayClient(client: _mockClient());
      await tester.pumpWidget(
        MaterialApp(home: TakoPlaySearchPage(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tako-Play 动漫'), findsOneWidget);
      expect(find.text('One Piece'), findsOneWidget);
      expect(find.text('Episode 1100'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'naruto');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('Naruto'), findsOneWidget);
      expect(find.text('Bleach'), findsOneWidget);
      expect(find.text('One Piece'), findsNothing);
    });

    testWidgets('shows the empty-search message', (tester) async {
      final client = TakoPlayClient(
        client: MockClient((_) async => http.Response('<html></html>', 200)),
      );
      await tester.pumpWidget(
        MaterialApp(home: TakoPlaySearchPage(client: client)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('未找到「zzz」'), findsOneWidget);
    });

    testWidgets('reports a loading failure with a retry action', (
      tester,
    ) async {
      final client = TakoPlayClient(
        client: MockClient((_) async => http.Response('nope', 503)),
      );
      await tester.pumpWidget(
        MaterialApp(home: TakoPlaySearchPage(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('加载失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });
  });

  group('TakoPlayDetailPage', () {
    testWidgets('renders the detail and its episodes', (tester) async {
      final client = TakoPlayClient(client: _mockClient());
      await tester.pumpWidget(
        MaterialApp(
          home: TakoPlayDetailPage(anime: _anime, client: client),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Naruto'), findsWidgets);
      expect(find.text('A young ninja.'), findsOneWidget);
      expect(find.text('Ongoing · 2002 · 2 集'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('第1集'), findsOneWidget);
      expect(find.text('第2集'), findsOneWidget);
    });

    testWidgets('opens the player page for an episode', (tester) async {
      final client = TakoPlayClient(client: _mockClient());
      await tester.pumpWidget(
        MaterialApp(
          home: TakoPlayDetailPage(anime: _anime, client: client),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('第1集'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TakoPlayEpisodePage), findsOneWidget);
    });
  });

  group('TakoPlayEpisodePage', () {
    testWidgets('feeds the extracted stream to the host player', (
      tester,
    ) async {
      final client = TakoPlayClient(client: _mockClient());
      await tester.pumpWidget(
        MaterialApp(
          home: TakoPlayEpisodePage(
            episode: TakoEpisode(number: '1', link: _episodeUri),
            title: 'Naruto 第1集',
            client: client,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Naruto 第1集'), findsOneWidget);
    });

    testWidgets('shows an error with retry when nothing can be extracted', (
      tester,
    ) async {
      final client = TakoPlayClient(
        client: MockClient((_) async => http.Response('gone', 404)),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: TakoPlayEpisodePage(
            episode: TakoEpisode(number: '1', link: _episodeUri),
            client: client,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('播放失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });
  });
}
