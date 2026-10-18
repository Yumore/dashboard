import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_info_data.dart';
import 'package:dashboard/features/comic/picacomic/core/comic_source_registry.dart';
import 'package:dashboard/features/comic/picacomic/core/history_type.dart';
import 'package:dashboard/features/comic/picacomic/data/history.dart';
import 'package:dashboard/features/comic/picacomic/data/local_favorites.dart';
import 'package:dashboard/features/comic/picacomic/js/comic_source_parse_exception.dart';
import 'package:dashboard/features/comic/picacomic/js/js_rule_kind.dart';
import 'package:dashboard/features/comic/picacomic/js/source_script_loader.dart';
import 'package:dashboard/features/comic/picacomic/js/source_script_parser.dart';
import 'package:dashboard/features/comic/picacomic/network/eh_models.dart';
import 'package:dashboard/features/comic/picacomic/network/eh_network.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_network.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_search.dart';
import 'package:dashboard/features/comic/picacomic/network/htmanga_parsing.dart';
import 'package:dashboard/features/comic/picacomic/network/htmanga_network.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_aes.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_comics_order.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_headers.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_network.dart';
import 'package:dashboard/features/comic/picacomic/network/nhentai_network.dart';
import 'package:dashboard/features/comic/picacomic/network/picacg_headers.dart';
import 'package:dashboard/features/comic/picacomic/network/picacg_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One scripted HTTP answer.
class _FakeResponse {
  _FakeResponse(this.status, {this.body = ''});

  final int status;
  final String body;
}

/// Network-free [HttpClientAdapter]: records every request and replays
/// hand-written fixtures. Nothing in this file touches a socket.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.responses);

  final List<_FakeResponse> responses;
  final List<RequestOptions> requests = [];
  int _index = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = _index < responses.length ? _index : responses.length - 1;
    _index++;
    final response = responses[index];
    return ResponseBody.fromString(
      response.body,
      response.status,
      headers: {
        Headers.contentTypeHeader: ['text/html; charset=utf-8'],
      },
    );
  }
}

Dio _dio(_FakeAdapter adapter, {String baseUrl = ''}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = adapter;
  return dio;
}

const String _jmSecret = '185Hcomic3PAPP7R';

List<int> _jmKey(int time) =>
    utf8.encode(md5.convert(utf8.encode('$time$_jmSecret')).toString());

/// Encrypts [json] the way the 禁漫天堂 API answers: AES-ECB with the
/// md5-derived key, wrapped in `{"data": "<base64>"}`.
String _jmEnvelope(String json, int time, {int pad = 0}) {
  final base = utf8.encode(json);
  // AES-ECB has no padding here, so pad with spaces; convertData trims the
  // plaintext back at the last `}`/`]`.
  final missing = (JmAesEcb.blockSize - base.length % JmAesEcb.blockSize) %
      JmAesEcb.blockSize;
  final cipher = JmAesEcb(_jmKey(time)).encrypt([
    ...base,
    ...List<int>.filled(missing + pad, 0x20),
  ]);
  return jsonEncode({'data': base64Encode(cipher)});
}

String _picacgDoc({
  String id = 'c1',
  String title = 'Title',
  String author = 'Author',
  int likes = 3,
  int pages = 5,
  String fileServer = 'https://fs.example',
  String path = 'p.jpg',
}) =>
    '{"_id":"$id","title":"$title","author":"$author",'
    '"likesCount":$likes,"pagesCount":$pages,'
    '"tags":["tagA"],"categories":["catA"],'
    '"thumb":{"fileServer":"$fileServer","path":"$path"}}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------------ picacg
  group('picacg protocol', () {
    test('nonce is a dash-less v1 UUID', () {
      final nonce = createNonce(
        timestampMicros: 0,
        clockSequence: 0,
        node: const [0, 0, 0, 0, 0, 0],
      );
      expect(nonce, '138140001dd211b28000010000000000');
      expect(nonce.length, 32);
      expect(nonce.contains('-'), isFalse);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(nonce), isTrue);
      expect(nonce[12], '1', reason: 'version nibble');
      expect(nonce[16], '8', reason: 'RFC 4122 variant');
    });

    test('signature is HMAC-SHA256 over the lowercased concatenation', () {
      // path + time + nonce + method + apiKey, lowercased, keyed by the
      // hard-coded secret of picacg_network/headers.dart.
      expect(
        createSignature('comics?page=1', 'N', '1700000000', 'get'),
        '6afb4f0043405ea1c18fd7333cc94a94344b7b00218a887f77208fdbb1a69f22',
      );
      // The method is part of the signed payload.
      expect(
        createSignature('comics?page=1', 'N', '1700000000', 'post'),
        isNot(createSignature('comics?page=1', 'N', '1700000000', 'get')),
      );
    });

    test('header map carries the exact picacg app identification', () {
      final headers = buildPicacgHeaders(
        method: 'get',
        token: 'tok',
        url: 'comics?page=1',
        nonce: 'N',
        timestampSeconds: 1700000000,
      );
      expect(headers['api-key'], 'C69BAF41DA5ABD1FFEDC6D2FEA56B');
      expect(headers['accept'], 'application/vnd.picacomic.com.v1+json');
      expect(headers['app-channel'], '3');
      expect(headers['authorization'], 'tok');
      expect(headers['time'], '1700000000');
      expect(headers['nonce'], 'N');
      expect(headers['app-version'], '2.2.1.3.3.4');
      expect(headers['app-build-version'], '45');
      expect(headers['image-quality'], 'original');
      expect(headers['app-platform'], 'android');
      expect(headers['user-agent'], 'okhttp/3.8.1');
      expect(headers['version'], 'v1.4.1');
      expect(headers['Host'], 'picaapi.picacomic.com');
      expect(
        headers['signature'],
        createSignature('comics?page=1', 'N', '1700000000', 'get'),
      );
    });

    test('every request is signed over the relative path', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: '{"data":{"comics":{"docs":[],"pages":1}}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      await network.search('kw', 'dd', 2);
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/comics/advanced-search');
      expect(request.uri.queryParameters['page'], '2');
      expect(request.headers['api-key'], picacgApiKey);
      expect(request.headers['authorization'], 'tok');
      // The signature covers the relative path, not the absolute url.
      expect(
        request.headers['signature'],
        createSignature(
          'comics/advanced-search?page=2',
          request.headers['nonce'] as String,
          request.headers['time'] as String,
          'post',
        ),
      );
    });

    test('search sends keyword and sort in the body', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: '{"data":{"comics":{"docs":[${_picacgDoc()}],"pages":3}}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      final res = await network.search('keyword', 'ld', 1);
      expect(res.data.length, 1);
      expect(res.subData, 3);
      expect(adapter.requests.single.data, {'keyword': 'keyword', 'sort': 'ld'});
    });

    test('comic docs map onto BaseComic with the /static/ image rule', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: '{"data":{"comics":{"docs":[${_picacgDoc()}],"pages":1}}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      final res = await network.search('k', 'dd', 1);
      final comic = res.data.single;
      expect(comic.id, 'c1');
      expect(comic.title, 'Title');
      expect(comic.subTitle, 'Author');
      expect(comic.cover, 'https://fs.example/static/p.jpg');
      expect(comic.description, '3 pages');
      expect(comic.tags, containsAll(<String>['tagA', 'catA']));
    });

    test('category comics use c=<category>&s=<sort>', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '{"data":{"comics":{"docs":[],"pages":1}}}'),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      await network.getCategoryComics(category: '全彩', page: 1, sort: 'ld');
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/comics');
      expect(uri.queryParameters['c'], '全彩');
      expect(uri.queryParameters['s'], 'ld');
      expect(uri.queryParameters['page'], '1');
    });

    test('latest is comics?s=dd and random is comics/random', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '{"data":{"comics":{"docs":[],"pages":1}}}'),
        _FakeResponse(
          200,
          body:
              '{"data":{"comics":[{"_id":"r1","title":"R","author":"A",'
              '"totalLikes":9,"thumb":{"fileServer":"https://fs","path":"r.jpg"}}]}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      await network.getLatest(2);
      expect(adapter.requests[0].uri.path, '/comics');
      expect(adapter.requests[0].uri.queryParameters['s'], 'dd');
      expect(adapter.requests[0].uri.queryParameters['page'], '2');

      final random = await network.getRandomComics();
      expect(adapter.requests[1].uri.path, '/comics/random');
      expect(random.data.single.id, 'r1');
      expect(random.data.single.cover, 'https://fs/static/r.jpg');
      expect(random.data.single.description, '9 pages');
    });

    test('favourites encode the sort direction in s=', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '{"data":{"comics":{"docs":[],"pages":1}}}'),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      await network.getFavorites(2, newToOld: false);
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/users/favourite');
      expect(uri.queryParameters['s'], 'da');
      expect(uri.queryParameters['page'], '2');
    });

    test('leaderboard requests tt=<time>&ct=VC', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '{"data":{"comics":[]}}'),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      await network.getLeaderboard('D7');
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/comics/leaderboard');
      expect(uri.queryParameters['tt'], 'D7');
      expect(uri.queryParameters['ct'], 'VC');
    });

    test('episodes are paged until pages == page and returned reversed', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: '{"data":{"eps":{"docs":[{"title":"EP1"}],"pages":2}}}',
        ),
        _FakeResponse(
          200,
          body: '{"data":{"eps":{"docs":[{"title":"EP2"}],"pages":2}}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      final eps = await network.getEps('c1');
      expect(eps.data, ['EP2', 'EP1']);
      expect(adapter.requests.length, 2);
      expect(adapter.requests[0].uri.path, '/comics/c1/eps');
      expect(adapter.requests[0].uri.queryParameters['page'], '1');
      expect(adapter.requests[1].uri.queryParameters['page'], '2');
    });

    test('pages are paged by order and use media.fileServer + /static/', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body:
              '{"data":{"pages":{"docs":[{"media":{"fileServer":"https://fs",'
              '"path":"1.jpg"}}],"pages":2}}}',
        ),
        _FakeResponse(
          200,
          body:
              '{"data":{"pages":{"docs":[{"media":{"fileServer":"https://fs",'
              '"path":"2.jpg"}}],"pages":2}}}',
        ),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      final pages = await network.getComicContent('c1', 2);
      expect(pages.data, [
        'https://fs/static/1.jpg',
        'https://fs/static/2.jpg',
      ]);
      expect(adapter.requests[0].uri.path, '/comics/c1/order/2/pages');
      expect(adapter.requests.length, 2);
    });

    test('400 surfaces the API message, 401 retries after re-login', () async {
      final badAdapter = _FakeAdapter([
        _FakeResponse(400, body: '{"message":"bad sort"}'),
      ]);
      final bad = PicacgNetwork(
        dio: _dio(badAdapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
      );
      final badRes = await bad.getLatest(1);
      expect(badRes.error, isTrue);
      expect(badRes.errorMessageWithoutNull, 'bad sort');

      var reLogins = 0;
      final adapter = _FakeAdapter([
        _FakeResponse(401, body: '{"message":"token expired"}'),
        _FakeResponse(200, body: '{"data":{"comics":{"docs":[],"pages":1}}}'),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
        tokenProvider: () => 'tok',
        reLogin: () async {
          reLogins++;
          return true;
        },
      );
      final res = await network.getLatest(1);
      expect(res.error, isFalse);
      expect(reLogins, 1);
      expect(adapter.requests.length, 2);
    });

    test('login posts email/password to auth/sign-in', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '{"data":{"token":"sess-token"}}'),
      ]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
      );
      final res = await network.login('a@b.c', 'pw');
      expect(res.data, 'sess-token');
      expect(adapter.requests.single.uri.path, '/auth/sign-in');
      expect(adapter.requests.single.data, {
        'email': 'a@b.c',
        'password': 'pw',
      });
    });

    test('a request without a token never reaches the network', () async {
      final adapter = _FakeAdapter([_FakeResponse(200, body: '{}')]);
      final network = PicacgNetwork(
        dio: _dio(adapter, baseUrl: PicacgNetwork.picacgApiUrl),
      );
      final res = await network.getLatest(1);
      expect(res.errorMessageWithoutNull, '未登录');
      expect(adapter.requests, isEmpty);
    });
  });

  // --------------------------------------------------------------- e-hentai
  group('e-hentai protocol', () {
    test('star widget position maps to the 0.5..5 scale', () {
      expect(getStarsFromPosition('background-position:0px -1px'), 5);
      expect(getStarsFromPosition('background-position:0px -21px'), 4.5);
      expect(getStarsFromPosition('background-position:-16px -1px'), 4);
      expect(getStarsFromPosition('background-position:-16px -21px'), 3.5);
      expect(getStarsFromPosition('background-position:-32px -1px'), 3);
      expect(getStarsFromPosition('background-position:-32px -21px'), 2.5);
      expect(getStarsFromPosition('background-position:-48px -1px'), 2);
      expect(getStarsFromPosition('background-position:-48px -21px'), 1.5);
      expect(getStarsFromPosition('background-position:-64px -1px'), 1);
      expect(getStarsFromPosition('background-position:-64px -21px'), 0.5);
      expect(getStarsFromPosition('background-position:0px -99px;'), 0.5);
    });

    test('gallery id is read between /g/ and the next slash', () {
      expect(getGalleryId('https://e-hentai.org/g/123456/abcdef0123/'), '123456');
      expect(getGalleryId('https://exhentai.org/g/99/x'), '99');
    });

    test('inline JS variables feed the gallery auth map', () {
      final variables = parseJsVariables(
        'var gid = 123; var token = "abc"; var x = 5;',
      );
      expect(variables['gid'], '123');
      expect(variables['token'], 'abc');
      expect(variables['x'], '5');
    });

    test('thumbnail key comes from the url() form or /m/<n>/ fallback', () {
      expect(
        EhNetwork.extractThumbnailKey(
          'background:transparent url(https://ehgt.org/m/12345/tn/001.jpg) 0 0',
        ),
        'https://ehgt.org/m/12345/tn',
      );
      expect(
        EhNetwork.extractThumbnailKey('background:url(https://ehgt.org/m/777/) no-repeat'),
        'https://ehgt.org/m/777',
      );
      expect(
        EhNetwork.extractThumbnailKey('background: transparent /m/777/'),
        '777',
      );
      expect(EhNetwork.extractThumbnailKey('background:red'), isNull);
    });

    test('thumbnail urls page every 20 images', () {
      expect(buildEhThumbnailUrl('https://k/m/01', '123', 0), 'https://k/m/01/123-0.jpg');
      expect(buildEhThumbnailKey('https://k', 0), 'https://k/m/00');
      expect(buildEhThumbnailKey('https://k', 20), 'https://k/m/01');
      expect(buildEhThumbnailKey('https://k', 41), 'https://k/m/02');
    });

    test('search builds f_search/f_cats/f_spf/f_spt/f_srdd', () async {
      final adapter = _FakeAdapter([_FakeResponse(200, body: '<html></html>')]);
      final network = EhNetwork(dio: _dio(adapter));
      await network.search('abc   def', fCats: 1024, minStars: 3);
      final query = adapter.requests.single.uri.queryParameters;
      expect(adapter.requests.single.uri.path, '/');
      expect(query['f_search'], 'abc def');
      expect(query['f_cats'], '1024');
      expect(query['f_srdd'], '3');
      expect(query.containsKey('f_spf'), isFalse);
    });

    test('search rewrites quoted alternatives with a first-word anchor', () {
      expect(EhNetwork.normalizeKeyword('a  b'), 'a b');
      expect(
        EhNetwork.normalizeKeyword('female:"big breasts | small breasts"'),
        'female:"big breasts\$"',
      );
    });

    test('reader page 1 has no p= and page n>1 is zero based', () async {
      const html =
          '<div id="gdt"><div class="gdtm"><div><a href="https://e/s/1">1</a>'
          '</div></div><div class="gdtl"><a href="https://e/s/2">2</a></div></div>';
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: html),
        _FakeResponse(200, body: html),
      ]);
      final network = EhNetwork(dio: _dio(adapter));
      final first = await network.getReaderLinks('https://e-hentai.org/g/1/a/', 1);
      expect(first.data, ['https://e/s/1', 'https://e/s/2']);
      expect(adapter.requests[0].uri.toString(), 'https://e-hentai.org/g/1/a/');

      await network.getReaderLinks('https://e-hentai.org/g/1/a/', 2);
      expect(adapter.requests[1].uri.queryParameters['p'], '1');
    });

    test('image link is /s/<imgKey>/<gid>-<page>?nl=', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: '<div id="i3"><a><img src="https://img.example/1.jpg"></a></div>',
        ),
      ]);
      final network = EhNetwork(dio: _dio(adapter));
      final res = await network.getImageLinkWithNl('123', 'KEY', 2, '');
      expect(res.data, 'https://img.example/1.jpg');
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/s/KEY/123-2');
      expect(uri.queryParameters['nl'], '');
    });

    test('gallery parsing reads tags, pages, rating and thumbnail key', () async {
      const html = '''
<h1 id="gn">Gallery Title</h1><h1 id="gj">Sub Title</h1>
<div id="taglist"><table><tbody>
<tr><td class="tc">female:</td><td><a>big breasts</a></td></tr>
<tr><td class="tc">artist:</td><td><a>someone</a></td></tr>
</tbody></table></div>
<table><tbody><tr><td class="gdt2">12 pages</td></tr></tbody></table>
<div id="gleft"><div id="gd1"><div style="background:transparent url(https://ehgt.org/t/1.jpg)"></div></div></div>
<div id="gdn"><a>Uploader</a></div>
<div id="rating_image" style="background-position:-32px -1px"></div>
<div id="rating_label">3.00</div>
<div class="cs">Doujinshi</div>
<div id="gdd"><table><tbody><tr><td class="gdt2">2020-01-02</td></tr></tbody></table></div>
<div class="gdtm"><div style="background:url(https://ehgt.org/m/42/tn/x.jpg)"></div></div>
<div id="favoritelink"> Add to Favorites</div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = EhNetwork(dio: _dio(adapter));
      final res = await network.getGalleryInfo('https://e-hentai.org/g/123/abc/');
      // Res 的 errorMessageWithoutNull 在没有错误时返回 'Unknown Error'，成功判定应看 error。
      expect(res.error, isFalse);
      final gallery = res.data;
      expect(gallery.title, 'Gallery Title');
      expect(gallery.subTitle, 'Sub Title');
      expect(gallery.maxPage, 12);
      expect(gallery.tags['female'], ['big breasts']);
      expect(gallery.tags['artist'], ['someone']);
      expect(gallery.stars, 3);
      expect(gallery.rating, '3.00');
      expect(gallery.type, 'Doujinshi');
      expect(gallery.uploader, 'Uploader');
      expect(gallery.time, '2020-01-02');
      expect(gallery.coverPath, 'https://ehgt.org/t/1.jpg');
      expect(gallery.auth?['thumbnailKey'], 'https://ehgt.org/m/42/tn');
      expect(gallery.favorite, isFalse);
    });

    test('comments require ?hc=1 and map the c1 blocks', () async {
      const html = '''
<a name="comment_9"></a>
<div class="c1"><div class="c3"><a href="#">Alice</a> Posted on 2020-01-01 10:00 by
<span>2020-01-01 10:00</span></div>
<div class="c6">hello world</div><div class="c5"><span>3</span></div>
<a id="comment_vote_up_9" style="opacity:1"></a></div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = EhNetwork(dio: _dio(adapter));
      final res = await network.getComments('https://e-hentai.org/g/1/a/');
      expect(adapter.requests.single.uri.queryParameters['hc'], '1');
      expect(res.error, isFalse, reason: res.errorMessageWithoutNull);
      final comment = res.data.single;
      expect(comment.name, 'Alice');
      expect(comment.content, 'hello world');
      expect(comment.time, '2020-01-01 10:00');
      expect(comment.id, '9');
      expect(comment.voteUp, isTrue);
    });
  });

  // ---------------------------------------------------------------------- jm
  group('jm protocol', () {
    test('AES-ECB matches the FIPS-197 AES-128 vector', () {
      final key = [for (var i = 0; i < 16; i++) i];
      final plain = [
        0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, //
        0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff,
      ];
      final cipher = JmAesEcb(key).encrypt(plain);
      expect(
        cipher.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        '69c4e0d86a7b0430d8cdb78070b4c55a',
      );
      expect(JmAesEcb(key).decrypt(cipher), plain);
    });

    test('convertData decrypts with the md5 time key and trims padding', () {
      const json = '{"data":{"id":1}}';
      // Two AES blocks: 17 bytes of json plus 15 spaces that convertData trims.
      final plain = [...utf8.encode(json), ...List<int>.filled(15, 0x20)];
      final cipher = JmAesEcb(_jmKey(1700000000)).encrypt(plain);
      final decoded = JmNetwork.convertData(base64Encode(cipher), 1700000000);
      expect(decoded, json);
    });

    test('headers carry the md5 token and base url host', () {
      final headers = JmHeaderBuilder.build(
        time: 1700000000,
        baseUrl: 'https://www.jmeadpoolcdn.one',
        device: 'abc123456',
      );
      // md5("1700000000" + "18comicAPPContent")
      expect(headers['token'], '8be524e958f97f014ddf2a570b011305');
      expect(headers['tokenparam'], '1700000000,1.7.2');
      expect(headers['Host'], 'www.jmeadpoolcdn.one');
      expect(headers['accept-encoding'], 'gzip');
    });

    test('latest hits /latest?&page=<n> and returns the 99999 sentinel', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(
          200,
          body: _jmEnvelope('{"data":{"id":1}}', 1700000000),
        ),
      ]);
      final network = JmNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.jmeadpoolcdn.one',
        clock: () => 1700000000,
      );
      final res = await network.getLatest(1);
      expect(adapter.requests.single.uri.path, '/latest');
      expect(adapter.requests.single.uri.queryParameters['page'], '1');
      expect(adapter.requests.single.headers['token'], '8be524e958f97f014ddf2a570b011305');
      expect(res.subData, 99999);
    });

    test('search omits page for page 1 and uses + for spaces', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: _jmEnvelope('{"data":{"id":1}}', 1700000000)),
        _FakeResponse(200, body: _jmEnvelope('{"data":{"id":1}}', 1700000000)),
      ]);
      final network = JmNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.jmeadpoolcdn.one',
        clock: () => 1700000000,
      );
      await network.search('abc def', 1, JmComicsOrder.latest);
      expect(adapter.requests[0].uri.path, '/search');
      expect(adapter.requests[0].uri.queryParameters['search_query'], 'abc def');
      expect(adapter.requests[0].uri.queryParameters['o'], 'mr');
      expect(adapter.requests[0].uri.queryParameters.containsKey('page'), isFalse);

      await network.search('abc def', 3, JmComicsOrder.maxLikes);
      expect(adapter.requests[1].uri.queryParameters['page'], '3');
      expect(adapter.requests[1].uri.queryParameters['o'], 'tf');
    });

    test('album path and empty payload handling', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: _jmEnvelope('{"data":{"id":1}}', 1700000000)),
      ]);
      final network = JmNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.jmeadpoolcdn.one',
        clock: () => 1700000000,
      );
      await network.getComicInfo('42');
      expect(adapter.requests.single.uri.path, '/album');
      expect(adapter.requests.single.uri.queryParameters['id'], '42');
    });
  });

  // ---------------------------------------------------------------- htmanga
  group('htmanga protocol', () {
    test('aid and favourite id are scraped from urls and onclicks', () {
      expect(
        HtmangaParsing.aidFromLink('https://www.wnacg.com/photos-index-aid-1234.html'),
        '1234',
      );
      expect(HtmangaParsing.aidFromLink('/albums.html'), isNull);
      expect(
        HtmangaParsing.favoriteIdFromOnclick(
          "javascript:del_fav('users-fav_del-id-5678.html')",
        ),
        '5678',
      );
    });

    test('counts and protocol relative images are normalised', () {
      expect(HtmangaParsing.digitsOnly('頁數：12 P'), '12');
      expect(HtmangaParsing.pagesFromText('12 P'), 12);
      expect(HtmangaParsing.absoluteImage('//cdn.example/a.jpg'), 'https://cdn.example/a.jpg');
      expect(HtmangaParsing.absoluteImage('https://x/a.jpg'), 'https://x/a.jpg');
      expect(
        HtmangaParsing.normalizeCoverPath('//cdn.example/c.jpg'),
        'https://cdn.example/c.jpg',
      );
    });

    test('paging rewrites albums urls and appends p= for searches', () {
      expect(
        HtmangaParsing.pageUrl('https://www.wnacg.com/albums.html', 3),
        'https://www.wnacg.com/albums-index-page-3.html',
      );
      expect(
        HtmangaParsing.pageUrl('https://www.wnacg.com/albums-index-cate-5.html', 2),
        'https://www.wnacg.com/albums-index-page-2-cate-5.html',
      );
      expect(
        HtmangaParsing.pageUrl('https://www.wnacg.com/search/?q=a&f=_all', 2),
        'https://www.wnacg.com/search/?q=a&f=_all&p=2',
      );
      expect(
        HtmangaParsing.pageUrl('https://www.wnacg.com/albums.html', 1),
        'https://www.wnacg.com/albums.html',
      );
    });

    test('search uses q/f/s/syn and paging adds p=', () async {
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: '<html><body></body></html>'),
      ]);
      final network = HtmangaNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.wnacg.com',
      );
      final res = await network.search('keyword', 2);
      expect(res.error, isFalse);
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/search/');
      expect(uri.queryParameters['q'], 'keyword');
      expect(uri.queryParameters['f'], '_all');
      expect(uri.queryParameters['s'], 'create_time_DESC');
      expect(uri.queryParameters['syn'], 'yes');
      expect(uri.queryParameters['p'], '2');
    });

    test('list parsing reads link/title/time/pages from the li blocks', () async {
      const html = '''
<div class="grid"><div class="gallary_wrap"><ul class="cc">
<li><div class="pic_box"><a href="https://www.wnacg.com/photos-index-aid-321.html">
<img src="//cdn.example/c.jpg"></a></div>
<div class="info"><div class="title"><a>Comic Name</a></div>
<div class="info_col">頁數：20 P，2021-05-06</div></div></li>
</ul></div></div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = HtmangaNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.wnacg.com',
      );
      final res = await network.getComicList('https://www.wnacg.com/albums.html', 1);
      expect(res.error, isFalse);
      final comic = res.data.single;
      expect(comic.id, '321');
      expect(comic.title, 'Comic Name');
      expect(comic.cover, 'https://cdn.example/c.jpg');
      expect(comic.pages, 20);
      expect(comic.time, '2021-05-06');
    });

    test('detail page parses category, pages, tags and photos', () async {
      const html = '''
<div class="userwrap"><h2>Detail Title</h2>
<div class="asTB"><div class="asTBcell uwthumb"><img src="//cdn.example/cover.jpg"></div></div></div>
<div class="asTBcell uwconn"><label>分類：同人志</label><label>頁數：18 P</label>
<p>A description</p><a class="tagshow" href="/tag/1">tag one</a></div>
<div class="asTBcell uwuinfo"><a><p>Uploader</p><img src="/avatar.png"></a><p><font>7</font></p></div>
<div class="pic_box tb"><a><img src="//cdn.example/1.jpg"></a></div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = HtmangaNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://www.wnacg.com',
      );
      final res = await network.getComicInfo('42');
      expect(res.error, isFalse);
      final info = res.data;
      expect(info.id, '42');
      expect(info.name, 'Detail Title');
      expect(info.category, '同人志');
      expect(info.pages, 18);
      expect(info.tags['tag one'], '/tag/1');
      expect(info.description, 'A description');
      expect(info.uploader, 'Uploader');
      expect(info.uploadNum, 7);
      expect(info.thumbnails, ['https://cdn.example/1.jpg']);
      expect(adapter.requests.single.uri.path, '/photos-index-page-1-aid-42.html');
    });
  });

  // ------------------------------------------------------------------ hitomi
  group('hitomi protocol', () {
    test('nozomi ids are little endian int32', () {
      final bytes = Uint8List(8);
      final data = ByteData.sublistView(bytes);
      data.setInt32(0, 0x01020304, Endian.little);
      data.setInt32(4, 7, Endian.little);
      expect(HitomiSearch.decodeNozomi(bytes), [0x01020304, 7]);
    });

    test('gallery block supplies title/type/language/tags/time/artist', () async {
      const html = '''
<h1 class="lillie"><a href="/manga/123.html">Gallery Name</a></h1>
<div class="artist-list"><a href="/artist/a.html">Artist Name</a></div>
<div class="dj-content">
<table class="dj-desc"><tbody>
<tr><td>Type</td><td>Doujinshi</td></tr>
<tr><td>Language</td><td>English</td></tr>
<tr><td>Tags</td><td class="relatedtags"><ul><li><a href="/tag/female.html">female</a></li></ul></td></tr>
</tbody></table>
<p>2020-02-03 04:05:06</p>
</div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = HiNetwork(dio: _dio(adapter));
      final res = await network.getComicInfoBrief('123');
      expect(res.error, isFalse);
      expect(adapter.requests.single.uri.path, '/galleryblock/123.html');
      final brief = res.data;
      expect(brief.name, 'Gallery Name');
      expect(brief.type, 'Doujinshi');
      expect(brief.lang, 'English');
      expect(brief.artist, 'Artist Name');
      expect(brief.time, '2020-02-03 04:05:06');
      expect(brief.tagList.single.name, 'female');
      expect(brief.link, endsWith('/manga/123.html'));
    });

    test('comic ids are read from numeric targets and .html links', () async {
      const block = '''
<h1 class="lillie"><a href="/manga/123.html">Name</a></h1>
<div class="dj-content">
<table class="dj-desc"><tbody><tr><td>Type</td><td>Doujinshi</td></tr></tbody></table>
<p>time</p></div>
''';
      final adapter = _FakeAdapter([
        _FakeResponse(200, body: block),
        _FakeResponse(200, body: 'var gallery = {"id": 5}'),
      ]);
      final network = HiNetwork(dio: _dio(adapter));
      try {
        // The truncated js payload cannot map onto HitomiComic; the request
        // path is what this test pins down.
        await network.getComicInfo('456');
      } catch (_) {}
      expect(adapter.requests[1].uri.path, '/galleries/456.js');

      final adapter2 = _FakeAdapter([
        _FakeResponse(200, body: block),
        _FakeResponse(200, body: 'var gallery = {"id": 9}'),
      ]);
      final network2 = HiNetwork(dio: _dio(adapter2));
      try {
        await network2.getComicInfo('https://hitomi.la/manga/999.html');
      } catch (_) {}
      expect(adapter2.requests[1].uri.path, '/galleries/999.js');
    });
  });

  // ----------------------------------------------------------------- nhentai
  group('nhentai protocol', () {
    test('search requests q/page and maps the gallery blocks', () async {
      const html = '''
<div id="content"><h1>25 results</h1>
<div class="gallery" data-tags="12227 1">
<a href="/g/123456/"><img data-src="https://i.nhentai.net/galleries/1/1.jpg">
<div class="caption">Some Title</div></a></div>
</div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = NhentaiNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://nhentai.net',
      );
      final res = await network.search('big breasts', 2);
      expect(res.error, isFalse);
      final uri = adapter.requests.single.uri;
      expect(uri.path, '/search/');
      expect(uri.queryParameters['q'], 'big breasts');
      expect(uri.queryParameters['page'], '2');
      expect(res.subData, 25);
      final comic = res.data.single;
      expect(comic.id, '123456');
      expect(comic.title, 'Some Title');
      expect(comic.cover, 'https://i.nhentai.net/galleries/1/1.jpg');
      expect(comic.lang, 'English');
    });

    test('language tags map to the documented names', () async {
      const html = '''
<div id="content"><h1>1 result</h1>
<div class="gallery" data-tags="6346"><a href="/g/1/">
<img data-src="https://i.nhentai.net/galleries/1/1.jpg">
<div class="caption">Japanese</div></a></div>
<div class="gallery" data-tags="29963"><a href="/g/2/">
<img data-src="https://i.nhentai.net/galleries/2/1.jpg">
<div class="caption">Chinese</div></a></div></div>
''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = NhentaiNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://nhentai.net',
      );
      final res = await network.search('x', 1);
      expect(res.data[0].lang, '日本語');
      expect(res.data[1].lang, '中文');
    });

    test('images are rebuilt from window._gallery media_id and t codes', () async {
      const html = r'''<html><body><script>
window._gallery = JSON.parse("{\u0022media_id\u0022:\u0022987\u0022,\u0022images\u0022:{\u0022pages\u0022:[{\u0022t\u0022:\u0022j\u0022},{\u0022t\u0022:\u0022p\u0022},{\u0022t\u0022:\u0022g\u0022}]}}");
</script></body></html>''';
      final adapter = _FakeAdapter([_FakeResponse(200, body: html)]);
      final network = NhentaiNetwork(
        dio: _dio(adapter),
        baseUrl: 'https://nhentai.net',
      );
      final res = await network.getImages('555');
      expect(res.error, isFalse);
      expect(adapter.requests.single.uri.path, '/g/555/1/');
      expect(res.data, [
        'https://i7.nhentai.net/galleries/987/1.jpg',
        'https://i7.nhentai.net/galleries/987/2.png',
        'https://i7.nhentai.net/galleries/987/3.gif',
      ]);
    });
  });

  // ------------------------------------------------------------------- core
  group('source registry and models', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ComicSourceRegistry.clear();
    });
    test('the six built-in sources keep their keys and order', () {
      final keys = ComicSourceRegistry.builtInSources
          .map((source) => source.key)
          .toList();
      expect(keys, ['picacg', 'ehentai', 'jm', 'hitomi', 'htmanga', 'nhentai']);
      expect(ComicSourceRegistry.builtInSources.every((s) => s.isBuiltIn), isTrue);
    });

    test('init registers the enabled sources and require throws otherwise', () async {
      await ComicSourceRegistry.init();
      expect(ComicSourceRegistry.sources.length, 6);
      expect(ComicSourceRegistry.find('hitomi')?.name, 'hitomi');
      expect(
        () => ComicSourceRegistry.require('nope'),
        throwsA(isA<StateError>()),
      );
      expect(ComicSourceRegistry.fromIntKey('jm'.hashCode)?.key, 'jm');
      ComicSourceRegistry.clear();
    });

    test('init honours enabledKeys', () async {
      await ComicSourceRegistry.init(enabledKeys: ['picacg', 'nhentai']);
      expect(
        ComicSourceRegistry.sources.map((source) => source.key),
        ['picacg', 'nhentai'],
      );
      ComicSourceRegistry.clear();
    });

    test('HistoryType names and lookups match the built-in order', () {
      expect(HistoryType.picacg.value, 0);
      expect(HistoryType.nhentai.value, 5);
      expect(HistoryType.nameOf(0), 'picacg');
      expect(HistoryType.nameOf(2), 'jm');
      expect(HistoryType.nameOf(99), isNull);
      expect(HistoryType.forSourceKey('htmanga'), HistoryType.htmanga);
      expect(HistoryType.forSourceKey('unknown-source').isBuiltIn, isFalse);
    });

    test('ComicInfoData json round trip keeps the wire keys', () {
      const comic = ComicInfoData(
        'T',
        'S',
        'C',
        'D',
        {
          '作者': ['a'],
        },
        {'1': 'EP1'},
        ['C'],
        null,
        1,
        null,
        'picacg',
        'c1',
        isFavorite: true,
      );
      final json = comic.toJson();
      expect(json['title'], 'T');
      expect(json['subTitle'], 'S');
      expect(json['sourceKey'], 'picacg');
      expect(json['comicId'], 'c1');
      expect(json['isFavorite'], true);
      final restored = ComicInfoData.fromJson(json);
      expect(restored.title, 'T');
      expect(restored.chapters, {'1': 'EP1'});
      expect(restored.tags['作者'], ['a']);
      expect(restored.target, 'c1');
      expect(restored.historyType, HistoryType.picacg);
    });
  });

  group('history persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('history rows survive a reload and track the last page', () async {
      final manager = HistoryManager();
      final other = HistoryManager();
      await manager.addHistory(
        History(
          type: HistoryType.picacg,
          time: 1000,
          title: 'T',
          cover: 'C',
          target: 'c1',
        ),
      );
      await manager.saveReadHistory(
        History(
          type: HistoryType.picacg,
          time: 2000,
          title: 'T',
          cover: 'C',
          ep: 3,
          page: 7,
          target: 'c1',
        ),
      );
      final row = await manager.find('c1');
      expect(row, isNotNull);
      expect(row!.page, 7);
      expect(row.ep, 3);
      expect(row.time, greaterThan(1000));
      // Persisted through shared_preferences, so a fresh instance sees it.
      final reloaded = await other.find('c1');
      expect(reloaded!.page, 7);
      await manager.addHistory(
        History(
          type: HistoryType.nhentai,
          time: 3000,
          title: 'T2',
          cover: 'C2',
          target: 'n1',
        ),
      );
      expect(await manager.count(), 2);
      expect(
        (await manager.getAll()).map((row) => row.target),
        containsAll(<String>['c1', 'n1']),
      );
      // saveReadHistory restamped c1 with the current time, so it is newest.
      expect((await manager.getRecent(limit: 1)).single.target, 'c1');
      await manager.remove('c1');
      expect(await manager.count(), 1);
      await manager.clear();
      expect(await manager.count(), 0);
    });
  });

  group('local favourites persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('folders, rows and lookups persist', () async {
      final manager = LocalFavoritesManager();
      await manager.init();
      final folder = await manager.createFolder('folder1');
      expect(folder, 'folder1');
      await manager.addComic(
        folder,
        FavoriteItem(
          target: 'c1',
          name: 'Title',
          author: 'Author',
          type: FavoriteType.picacg,
          tags: const ['tag'],
          coverPath: 'cover',
        ),
      );
      expect(manager.isFavorite('c1', FavoriteType.picacg), isTrue);
      expect(manager.find('c1', FavoriteType.picacg), [folder]);
      expect(manager.getAllComics(folder).single.name, 'Title');
      expect(manager.getAllComics(folder).single.displayOrder, greaterThan(0));

      final reloaded = LocalFavoritesManager();
      await reloaded.init();
      expect(reloaded.isFavorite('c1', FavoriteType.picacg), isTrue);

      await manager.removeComic(folder, 'c1', FavoriteType.picacg.key);
      expect(manager.isFavorite('c1', FavoriteType.picacg), isFalse);
    });

    test('nhentai keeps the historical favourite key 6', () {
      expect(FavoriteType.nhentai.key, 6);
      expect(FavoriteType.picacg.key, 0);
      expect(FavoriteType.fromSourceKey('nhentai'), FavoriteType.nhentai);
      expect(FavoriteType.nhentai.isBuiltIn, isTrue);
    });
  });

  // ------------------------------------------------------------- user JS
  group('user JS source contract', () {
    const validScript = '''
class MySource extends ComicSource {
  name = "My Source"
  key = "mysource"
  version = "1.2.3"
  loadComic(id) { return {} }
}
''';

    test('parses class name, literals and declared rules', () {
      final descriptor = const SourceScriptParser().parse(
        validScript,
        filePath: 'mysource.js',
      );
      expect(descriptor.className, 'MySource');
      expect(descriptor.name, 'My Source');
      expect(descriptor.key, 'mysource');
      expect(descriptor.version, '1.2.3');
      expect(descriptor.filePath, 'mysource.js');
      expect(descriptor.hasValidKey, isTrue);
      expect(descriptor.implementsRule(JsRuleKind.loadComic), isTrue);
      expect(descriptor.implementsRule(JsRuleKind.loadComicPages), isFalse);
      expect(descriptor.requiresJsRuntime, isTrue);
    });

    test('rejects scripts that are not ComicSource subclasses', () {
      expect(
        () => const SourceScriptParser().parse('var a = 1;'),
        throwsA(
          isA<ComicSourceParseException>().having(
            (error) => error.message,
            'message',
            'Invalid Content',
          ),
        ),
      );
    });

    test('keys with invalid characters are detected and rejected', () async {
      const script = '''
class Bad extends ComicSource {
  name = "Bad"
  key = "bad key!"
}
''';
      final descriptor = const SourceScriptParser().parse(script);
      expect(descriptor.key, 'bad key!');
      expect(descriptor.hasValidKey, isFalse);

      final loader = SourceScriptLoader(
        entries: const [SourceScriptEntry(filePath: 'bad.js', content: script)],
      );
      final sources = await loader.load();
      expect(sources, isEmpty);
      expect(loader.errors.single.message, 'key bad key! is invalid');
    });

    test('loader registers a source but reports the JS runtime as absent', () async {
      final loader = SourceScriptLoader(
        entries: const [
          SourceScriptEntry(filePath: 'mysource.js', content: validScript),
        ],
      );
      final sources = await loader.load();
      expect(sources.length, 1);
      expect(loader.errors, isEmpty);
      final source = sources.single;
      expect(source.key, 'mysource');
      expect(source.isBuiltIn, isFalse);
      expect(source.data['jsExecutionSupported'], isFalse);
      expect(source.data['unsupportedRules'], ['loadComic']);
      expect(loader.registrations.single.descriptor.key, 'mysource');
    });

    test('loader rejects duplicate keys', () async {
      final loader = SourceScriptLoader(
        existingKeys: {'mysource'},
        entries: const [
          SourceScriptEntry(filePath: 'a.js', content: validScript),
        ],
      );
      final sources = await loader.load();
      expect(sources, isEmpty);
      expect(loader.errors.single.message, 'key(mysource) already exists');
    });

    test('loader rejects scripts without a name', () async {
      final loader = SourceScriptLoader(
        entries: const [
          SourceScriptEntry(
            filePath: 'b.js',
            content: '''
class NoName extends ComicSource {
  key = "noname"
}
''',
          ),
        ],
      );
      final sources = await loader.load();
      expect(sources, isEmpty);
      expect(loader.errors.single.message, 'name is required');
    });
  });
}
