// Network free tests of the tsdm forum port under
// `lib/features/anime/tsdm/`.
//
// Everything here runs without a socket: url builders, query parameter rules,
// the in-memory cookie jar, the html parser helpers and the model mappings.
// The http layer is exercised through `package:http/testing.dart`'s
// `MockClient`, which is the only seam the port needs because `TsdmHttpClient`
// takes an injectable `http.Client`.
import 'dart:convert';
import 'dart:io';

import 'package:dashboard/features/anime/tsdm/tsdm_api_urls.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_exception.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_filter_state.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_query.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_html_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_notification_v2.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_post.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_search_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_string_ext.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_filter.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_thread_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_user_login_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Parse [html] into a document, the same way the repositories do.
dom.Document parseDoc(String html) => html_parser.parse(html);

void main() {
  group('TsdmApiUrls', () {
    test('keeps the public forum host and the page constants', () {
      expect(TsdmApiUrls.baseHost, 'www.tsdm39.com');
      expect(TsdmApiUrls.baseHostAlt, 'tsdm39.com');
      expect(TsdmApiUrls.baseUrl, 'https://www.tsdm39.com');
      expect(TsdmApiUrls.homePage, 'https://www.tsdm39.com/forum.php');
      expect(
        TsdmApiUrls.signUpPage,
        'https://www.tsdm39.com/member.php?mod=register.php',
      );
      expect(
        TsdmApiUrls.noAvatarUrl,
        'https://www.tsdm39.com/uc_server/images/noavatar_middle.gif',
      );
      expect(TsdmApiUrls.noticeUrl, endsWith('/home.php?mod=space&do=notice'));
      expect(TsdmApiUrls.readNoticeUrl, endsWith('do=notice&isread=1'));
      expect(
        TsdmApiUrls.personalMessageUrl,
        endsWith('do=pm&filter=privatepm'),
      );
      expect(
        TsdmApiUrls.broadcastMessageUrl,
        endsWith('do=pm&filter=announcepm'),
      );
      expect(TsdmApiUrls.searchUrl, 'https://www.tsdm39.com/plugin.php');
      expect(TsdmApiUrls.searchPluginId, 'Kahrpba:search');
      expect(TsdmApiUrls.userNotifyPluginId, 'Kahrpba:usernotify');
      expect(
        TsdmApiUrls.notificationV2UrlPrefix,
        endsWith('plugin.php?mobile=yes&tsdmapp=1&id=Kahrpba:usernotify&last_updated='),
      );
      expect(TsdmApiUrls.tmpImpellerWorkaroundUrls, const [
        'https://www.tsdm39.com/static/image/common/back.gif',
        'https://tsdm39.com/static/image/common/back.gif',
      ]);
    });

    test('builds the action urls with the source query layout', () {
      expect(
        TsdmApiUrls.threadUrl(tid: '100'),
        'https://www.tsdm39.com/forum.php?mod=viewthread&tid=100&extra=page%3D1&page=1',
      );
      expect(
        TsdmApiUrls.threadUrl(
          tid: '100',
          pageNumber: 3,
          orderType: '&ordertype=1',
          visibleUid: '&authorid=42',
        ),
        'https://www.tsdm39.com/forum.php?mod=viewthread&tid=100'
        '&extra=page%3D1&ordertype=1&authorid=42&page=3',
      );
      expect(
        TsdmApiUrls.logoutUrl('abc'),
        'https://www.tsdm39.com/member.php?mod=logging&action=logout&formhash=abc',
      );
      expect(
        TsdmApiUrls.redirectToPostUrl('9'),
        'https://www.tsdm39.com/forum.php?mod=redirect&goto=findpost&pid=9',
      );
      expect(
        TsdmApiUrls.threadJsonUrl(tid: '7', page: 2),
        'https://www.tsdm39.com/forum.php?mobile=yes&tsdmapp=1&mod=viewthread&tid=7&page=2',
      );
      expect(
        TsdmApiUrls.operationLogUrl('7'),
        endsWith('action=viewthreadmod&tid=7&infloat=yes&handlekey=viewthreadmod'
            '&inajax=1&ajaxtarget=fwin_content_viewthreadmod'),
      );
      expect(
        TsdmApiUrls.chatFullHistoryUrl('42'),
        endsWith('do=pm&subop=view&touid=42#last'),
      );
      expect(TsdmApiUrls.chatFullHistoryUrl('42', page: 2), contains('&page=2#last'));
      expect(
        TsdmApiUrls.chatRecentHistoryUrl('42'),
        endsWith('op=showmsg&msgonly=1&touid=42&pmid=0&inajax=1&daterange=2'),
      );
      expect(
        TsdmApiUrls.sendMessageUrl('42'),
        'https://www.tsdm39.com/home.php?mod=spacecp&ac=pm&op=send&touid=42&inajax=1',
      );
      expect(
        TsdmApiUrls.purchaseDialogUrl('1', '2'),
        contains('mod=misc&action=pay&tid=1&pid=2'),
      );
      expect(
        TsdmApiUrls.replyThreadUrl('21', '123'),
        startsWith('https://www.tsdm39.com/forum.php?mod=post&action=reply&fid=21&tid=123'),
      );
      expect(
        TsdmApiUrls.replyPostUrl('21', '123'),
        startsWith('https://www.tsdm39.com/forum.php?mod=post'),
      );
    });
  });

  group('TsdmThreadRepository url rules', () {
    test('maps page, author filter and order flags onto the thread url', () {
      expect(
        TsdmThreadRepository.buildThreadUrl(tid: '100'),
        TsdmApiUrls.threadUrl(tid: '100'),
      );
      expect(
        TsdmThreadRepository.buildThreadUrl(tid: '100', pageNumber: 4),
        endsWith('&extra=page%3D1&page=4'),
      );
      expect(
        TsdmThreadRepository.buildThreadUrl(tid: '100', onlyVisibleUid: '42'),
        contains('&authorid=42&page=1'),
      );
      // reverseOrder only decides when no explicit order is given.
      expect(
        TsdmThreadRepository.buildThreadUrl(tid: '100', reverseOrder: true),
        contains('&ordertype=1'),
      );
      expect(
        TsdmThreadRepository.buildThreadUrl(tid: '100', reverseOrder: false),
        contains('&ordertype=2'),
      );
      expect(
        TsdmThreadRepository.buildThreadUrl(
          tid: '100',
          reverseOrder: true,
          exactOrder: 3,
        ),
        contains('&ordertype=3'),
      );
      // A pid resolves through the redirect endpoint instead.
      expect(
        TsdmThreadRepository.buildThreadUrl(pid: '55'),
        TsdmApiUrls.redirectToPostUrl('55'),
      );
    });
  });

  group('TsdmForumQuery', () {
    test('writes the base parameters in insertion order', () {
      final query = TsdmForumQuery.build(fid: '21', filterState: const TsdmFilterState());
      expect(query.parameters, const {
        'mod': 'forumdisplay',
        'fid': '21',
        'page': '1',
      });
      expect(query.parameters.keys.toList(), const ['mod', 'fid', 'page']);
    });

    test('recommend filter adds recommend and a replaceable orderby', () {
      final recommended = TsdmForumQuery.build(
        fid: '21',
        pageNumber: 2,
        filterState: const TsdmFilterState(
          filterRecommend: TsdmFilterRecommend(recommend: true),
        ),
      );
      expect(recommended.parameters['page'], '2');
      expect(recommended.parameters['recommend'], '1');
      expect(recommended.parameters['orderby'], 'recommends');

      // A user selected order wins over the compound recommend orderby.
      final userOrder = TsdmForumQuery.build(
        fid: '21',
        filterState: const TsdmFilterState(
          filterRecommend: TsdmFilterRecommend(recommend: true),
          filterOrder: TsdmFilterOrder(name: '最新', orderBy: 'lastpost'),
        ),
      );
      expect(userOrder.parameters['orderby'], 'lastpost');
      expect(userOrder.parameters.keys.toList(), const [
        'mod',
        'fid',
        'page',
        'recommend',
        'orderby',
      ]);
    });

    test('writes every dedicated filter value', () {
      final query = TsdmForumQuery.build(
        fid: '21',
        filterState: const TsdmFilterState(
          filterType: TsdmFilterType(name: '动画', typeID: '5'),
          filterSpecialType: TsdmFilterSpecialType(name: '投票', specialType: '1'),
          filterDateline: TsdmFilterDateline(name: '一天', dateline: '1'),
          filterDigest: TsdmFilterDigest(digest: true),
        ),
      );
      expect(query.parameters['typeid'], '5');
      expect(query.parameters['specialtype'], '1');
      expect(query.parameters['dateline'], '1');
      expect(query.parameters['digest'], '1');
      expect(query.parameters.containsKey('orderby'), isFalse);
    });

    test('applies the extra filter only when the key already exists', () {
      final applied = TsdmForumQuery.build(
        fid: '21',
        filterState: const TsdmFilterState(
          filter: 'typeid',
          filterType: TsdmFilterType(name: '动画', typeID: '5'),
        ),
      );
      expect(applied.parameters['filter'], 'typeid');

      // Without a type filter there is no `typeid` key to alias, so the extra
      // filter is dropped instead of inventing one.
      final dropped = TsdmForumQuery.build(
        fid: '21',
        filterState: const TsdmFilterState(filter: 'typeid'),
      );
      expect(dropped.parameters.containsKey('filter'), isFalse);
    });
  });

  group('TsdmCookieStore', () {
    test('writes, reads and builds the request cookie header', () async {
      final store = TsdmCookieStore();
      await store.write('a', '1');
      await store.write('b', '2');

      expect(store.buildCookieHeader(), 'a=1; b=2');
      expect(store.read('a'), '1');
      expect(store.read('missing'), isNull);
      expect(store.readAll(), const {'a': '1', 'b': '2'});
      expect(store.isAuthed, isFalse);

      // `readAll` is a copy, the `cookies` snapshot is read only.
      store.readAll()['c'] = '3';
      expect(store.read('c'), isNull);
      expect(() => store.cookies['c'] = '3', throwsUnsupportedError);
    });

    test('never overwrites an authenticated cookie with an anonymous one', () async {
      final store = TsdmCookieStore();
      await store.write('auth', 'tsdm_auth=token');
      expect(store.isAuthed, isTrue);

      await store.write('auth', 'anonymous');
      expect(store.read('auth'), 'tsdm_auth=token');

      // Other cookies and the reverse direction are unaffected.
      await store.write('sid', 'xyz');
      expect(store.read('sid'), 'xyz');
      await store.write('sid', 'tsdm_auth=other');
      expect(store.read('sid'), 'tsdm_auth=other');
    });

    test('exposes the cookie names, lifetime and clears its jar', () async {
      expect(tsdmCookiePrefix, 'tsdm');
      expect(tsdmAuthCookieName, 'tsdm_auth');
      expect(tsdmCreditNoticeCookieName, 'tsdm_creditnotice');
      expect(TsdmCookieStore.defaultCookieTime, 2592000);

      final store = TsdmCookieStore();
      await store.write('a', '1');
      await store.write('b', '2');
      await store.delete('a');
      expect(store.read('a'), isNull);
      expect(store.read('b'), '2');

      store.clearCookies();
      expect(store.cookies, isEmpty);
      expect(store.buildCookieHeader(), '');
      await store.clearUserInfoAndCookie();
      expect(store.userLoginInfo.isComplete, isFalse);
    });
  });

  group('TsdmHttpClient', () {
    test('forces the desktop layout for forum hosts only', () async {
      final requests = <http.Request>[];
      final client = TsdmHttpClient(
        cookieStore: TsdmCookieStore(),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('ok', 200);
        }),
      );

      await client.get(TsdmApiUrls.homePage);
      await client.get('https://example.test/page');
      await client.get('${TsdmApiUrls.baseUrl}/forum.php?mobile=no');
      await client.get('https://${TsdmApiUrls.baseHostAlt}/forum.php');

      expect(requests[0].url.queryParameters['mobile'], 'no');
      expect(requests[0].url.queryParameters['mod'], isNull);
      expect(requests[1].url.queryParameters.containsKey('mobile'), isFalse);
      // An explicit mobile value is never duplicated.
      expect(requests[2].url.queryParametersAll['mobile'], const ['no']);
      expect(requests[3].url.host, TsdmApiUrls.baseHostAlt);
      expect(requests[3].url.queryParameters['mobile'], 'no');
    });

    test('can keep the desktop url and build a cookieless clone', () async {
      final requests = <http.Request>[];
      final store = TsdmCookieStore();
      await store.write('sid', 'abc');
      final client = TsdmHttpClient(
        cookieStore: store,
        forceDesktop: false,
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('ok', 200);
        }),
      );

      await client.get(TsdmApiUrls.homePage);
      expect(requests.single.url.toString(), TsdmApiUrls.homePage);
      expect(requests.single.headers['user-agent'], isNotEmpty);
      expect(requests.single.headers['cookie'], 'sid=abc');

      // The login flow clones the client without the session cookie.
      final clone = client.buildNoCookie();
      expect(clone.cookieStore, isNot(same(store)));
      expect(clone.cookieStore.cookies, isEmpty);
      expect(clone.forceDesktop, isFalse);
      expect(clone.transport, same(client.transport));
      expect(clone.userAgent, client.userAgent);
    });

    test('sends the cookie header and absorbs set-cookie headers', () async {
      final store = TsdmCookieStore();
      final requests = <http.Request>[];
      var calls = 0;
      final client = TsdmHttpClient(
        cookieStore: store,
        httpClient: MockClient((request) async {
          requests.add(request);
          calls++;
          if (calls == 1) {
            return http.Response('ok', 200, headers: const {
              'set-cookie': 'sid=abc; Path=/, '
                  'tsdm_creditnotice=tsdm_creditnotice=7; Path=/',
            });
          }
          if (calls == 2) {
            // A plain numeric credit notice value is not matched by the port:
            // the regex runs on the cookie value, not on the whole header.
            return http.Response('ok', 200, headers: const {
              'set-cookie': 'tsdm_creditnotice=12; Path=/',
            });
          }
          return http.Response('ok', 200);
        }),
      );

      await client.get(TsdmApiUrls.homePage);
      expect(store.read('sid'), 'abc');
      expect(store.read(tsdmCreditNoticeCookieName), 'tsdm_creditnotice=7');
      expect(client.pointsChanges, const [7]);

      await client.get(TsdmApiUrls.homePage);
      // The plain value replaces the stored cookie value, but records no point
      // change: the regex runs on the cookie value, not on the whole header.
      expect(client.pointsChanges, const [7]);
      expect(store.buildCookieHeader(), 'sid=abc; tsdm_creditnotice=12');

      await client.get(TsdmApiUrls.homePage);

      expect(requests[0].headers.containsKey('cookie'), isFalse);
      expect(
        requests[2].headers['cookie'],
        'sid=abc; tsdm_creditnotice=12',
      );
    });

    test('disables gzip for posts and single post redirects', () async {
      final requests = <http.Request>[];
      final client = TsdmHttpClient(
        cookieStore: TsdmCookieStore(),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response('ok', 200);
        }),
      );

      await client.get(TsdmApiUrls.homePage);
      await client.get(TsdmApiUrls.redirectToPostUrl('9'));
      await client.postForm(
        Uri.parse('${TsdmApiUrls.baseUrl}/member.php'),
        const {'a': '1'},
      );

      // Only the plain GET keeps the transport default (no accept-encoding).
      expect(requests[0].headers.containsKey('accept-encoding'), isFalse);
      expect(requests[1].headers['accept-encoding'], 'deflate, br');
      expect(requests[2].method, 'POST');
      expect(requests[2].headers['accept-encoding'], 'deflate, br');
      expect(requests[2].headers['content-type'], 'application/x-www-form-urlencoded');
      expect(requests[2].headers['accept'], isNotEmpty);
      expect(requests[2].headers['accept-language'], isNotEmpty);
    });

    test('throws HttpRequestFailedException for non 200 responses', () async {
      final client = TsdmHttpClient(
        cookieStore: TsdmCookieStore(),
        httpClient: MockClient((request) async => http.Response('nope', 404)),
      );

      final response = await client.get(TsdmApiUrls.homePage);
      expect(response.statusCode, 404);
      expect(response.data, 'nope');
      await expectLater(
        client.getDocument(Uri.parse(TsdmApiUrls.homePage)),
        throwsA(isA<HttpRequestFailedException>()),
      );
      await expectLater(
        client.getImage(Uri.parse('${TsdmApiUrls.baseUrl}/a.png')),
        throwsA(isA<HttpRequestFailedException>()),
      );
    });

    test('encodes a form body and decodes deflate payloads', () async {
      String? body;
      final client = TsdmHttpClient(
        cookieStore: TsdmCookieStore(),
        httpClient: MockClient((request) async {
          body = request.body;
          return http.Response('ok', 200);
        }),
      );

      await client.postForm(
        Uri.parse('${TsdmApiUrls.baseUrl}/member.php'),
        const {'a': '1', 'b': '中 文'},
      );
      expect(Uri.splitQueryString(body!), const {'a': '1', 'b': '中 文'});

      final raw = utf8.encode('<html>中文</html>');
      expect(decodeHttpBody(raw, null), '<html>中文</html>');
      expect(decodeHttpBody(raw, 'gzip'), '<html>中文</html>');
      expect(decodeHttpBody(ZLibEncoder().convert(raw), 'deflate'), '<html>中文</html>');
      expect(
        decodeHttpBody(ZLibEncoder(raw: true).convert(raw), 'deflate'),
        '<html>中文</html>',
      );
    });
  });

  group('TsdmStringParseExtension', () {
    test('parses padded and unpadded dates', () {
      expect(
        '2024-1-5 08:09:10'.parseToDateTimeUtc8(),
        DateTime(2024, 1, 5, 8, 9, 10),
      );
      expect(
        '2024-01-05 08:09:10'.parseToDateTimeUtc8(),
        DateTime(2024, 1, 5, 8, 9, 10),
      );
      expect('2024-1-5'.parseToDateTimeUtc8(), DateTime(2024, 1, 5));
      expect('2024-12-31'.parseToDateTimeUtc8(), DateTime(2024, 12, 31));
      // More than two space separated parts is refused outright.
      expect('2024-1-5 08:09:10 extra'.parseToDateTimeUtc8(), isNull);
      expect('abc'.parseToDateTimeUtc8(), isNull);
      expect('42'.parseToDateTimeUtc8(), isNull);

      expect('42'.parseToInt(), 42);
      expect('-7'.parseToInt(), -7);
      expect('4.2'.parseToInt(), isNull);
      expect('x'.parseToInt(), isNull);
    });

    test('prepends the host, truncates and reads query parameters', () {
      expect('static/a.png'.prependHost(), 'https://www.tsdm39.com/static/a.png');
      expect('https://cdn.test/a.png'.prependHost(), 'https://cdn.test/a.png');
      expect('http://cdn.test/a.png'.prependHost(), 'http://cdn.test/a.png');
      expect('mailto:a@b.c'.prependHost(), 'mailto:a@b.c');

      expect('abcdefgh'.truncate(5), 'abcde');
      expect('abcdefgh'.truncate(5, ellipsis: true), 'abcde...');
      expect('abc'.truncate(5), 'abc');

      const title = '标题 -  天使动漫论坛 - 梦开始的地方  -  Powered by Discuz!';
      expect(title.trimTitle(), '标题');
      expect('标题'.trimTitle(), '标题');

      const url = 'https://www.tsdm39.com/forum.php?mod=viewthread&tid=123';
      expect(url.tryGetQueryParameters(), const {
        'mod': 'viewthread',
        'tid': '123',
      });
      expect(url.uriQueryParameter('tid'), '123');
      expect(url.uriQueryParameter('missing'), isNull);
      expect(url.tryParseAsUri()?.path, '/forum.php');
      // An invalid uri never throws, it is reported as null.
      expect('http://[::1'.tryParseAsUri(), isNull);
      expect('http://[::1'.tryGetQueryParameters(), isNull);
      expect('http://[::1'.uriQueryParameter('a'), isNull);
    });

    test('obscures strings to a fixed star width', () {
      expect(''.obscured(), '<empty string>');
      expect('alice'.obscured(), '********');
      expect('abcdefghij'.obscured(), 'a*******');
      expect('abcdefghij'.obscured(4), 'a***');
      expect('abcdefghij'.obscured(1), 'a*');
    });
  });

  group('TsdmDocumentGrepExtension pagination', () {
    test('reads the current page and the total page count', () {
      final paged = parseDoc(
        '<div class="pg"><a href="?page=1">1</a><strong>2</strong></div>',
      );
      expect(paged.currentPage(), 2);
      // A trailing strong node marks the current page as the last page.
      expect(paged.totalPages(), 2);

      final skipped = parseDoc(
        '<div class="pg"><a href="?page=1">1</a>'
        '<a class="last" href="?page=42">xxxx42</a></div>',
      );
      expect(skipped.currentPage(), isNull);
      // The port strips a fixed four character prefix of the a.last label.
      expect(skipped.totalPages(), 42);

      final tooShort = parseDoc(
        '<div class="pg"><a href="?page=1">1</a>'
        '<a class="last" href="?page=9">9</a></div>',
      );
      expect(tooShort.totalPages(), 1);

      // No a.last node: the maximum plain anchor wins, classed ones are skipped.
      final plain = parseDoc(
        '<div class="pg"><a href="?page=1">1</a><a href="?page=2">2</a>'
        '<a class="next" href="?page=3">3</a></div>',
      );
      expect(plain.totalPages(), 2);

      final bare = parseDoc('<html><body><p>no pagination</p></body></html>');
      expect(bare.currentPage(), isNull);
      expect(bare.totalPages(), 1);
    });

    test('detects whether another page can be loaded', () {
      final more = parseDoc(
        '<div id="pgt"><div class="pg"><a href="?page=2">2</a></div></div>',
      );
      expect(more.checkCanLoadMore(), isTrue);

      final last = parseDoc(
        '<div id="pgt"><div class="pg"><a href="?page=1">1</a>'
        '<strong>2</strong></div></div>',
      );
      expect(last.checkCanLoadMore(), isFalse);

      // Without the pgt wrapper or the inner pg node nothing can be loaded.
      expect(
        parseDoc('<div class="pg"><a href="?page=2">2</a></div>').checkCanLoadMore(),
        isFalse,
      );
      expect(parseDoc('<div id="pgt"></div>').checkCanLoadMore(), isFalse);
    });
  });

  group('TsdmElementGrepExtension', () {
    test('reaches deep text, upper tag names and sibling nodes', () {
      final document = parseDoc(
        '<div id="root"><span><em>42</em></span><b>tail</b></div>',
      );
      final root = document.querySelector('#root')!;
      expect(root.tagNameUpper, 'DIV');
      expect(root.firstEndDeepText(), '42');
      expect(root.lastEndDeepText(), 'tail');
      expect(root.childAtOrNull(0)?.localName, 'span');
      expect(root.childAtOrNull(1)?.localName, 'b');
      expect(root.childAtOrNull(2), isNull);
      expect(root.innerHtmlEx(), contains('<em>42</em>'));
      expect(root.innerTextEx(), contains('42'));

      final siblings = parseDoc(
        '<p><span id="s1">a</span><span id="s2">b</span></p>',
      );
      final first = siblings.querySelector('#s1')!;
      final second = siblings.querySelector('#s2')!;
      expect(first.nextNode, same(second));
      expect(second.previousNode, same(first));
      expect(first.previousNode, isNull);
      expect(second.nextNode, isNull);
    });

    test('resolves firstHref and image urls', () {
      final withHref = parseDoc(
        '<div id="root"><p><a href="https://a.test/1">t</a></p></div>',
      );
      expect(withHref.querySelector('#root')!.firstHref(), 'https://a.test/1');
      expect(
        parseDoc('<div id="root"><p>plain</p></div>')
            .querySelector('#root')!
            .firstHref(),
        isNull,
      );

      final zoom = parseDoc(
        '<img id="i" zoomfile="static/image/a.png" src="b.png">',
      ).querySelector('#i')!;
      expect(zoom.imageUrl(), 'https://www.tsdm39.com/static/image/a.png');
      expect(zoom.dataOriginalOrSrcImgUrl(), 'b.png');

      final original = parseDoc(
        '<img id="i" data-original="o.png" src="s.png">',
      ).querySelector('#i')!;
      expect(original.dataOriginalOrSrcImgUrl(), 'o.png');

      final absolute = parseDoc(
        '<img id="i" src="https://cdn.test/x.png">',
      ).querySelector('#i')!;
      expect(absolute.imageUrl(), 'https://cdn.test/x.png');

      final relative = parseDoc('<img id="i" src="a.png">').querySelector('#i')!;
      expect(relative.imageUrl(), 'https://www.tsdm39.com/a.png');

      expect(parseDoc('<img id="i">').querySelector('#i')!.imageUrl(), isNull);
    });

    test('parses li/em pairs and table rows', () {
      final text = parseDoc('<ul><li><em>积分</em> 100</li></ul>')
          .querySelector('li')!;
      expect(text.parseLiEmNode(), ('积分', '100'));

      final element = parseDoc(
        '<ul><li><em>状态</em><b>正常</b>其他</li></ul>',
      ).querySelector('li')!;
      expect(element.parseLiEmNode(), ('状态', '<b>正常</b>其他'));
      expect(element.parseLiEmNode(second: true), ('状态', '正常'));

      expect(
        parseDoc('<ul><li><b>k</b>v</li></ul>')
            .querySelector('li')!
            .parseLiEmNode(),
        isNull,
      );
      expect(
        parseDoc('<ul><li><em></em>v</li></ul>')
            .querySelector('li')!
            .parseLiEmNode(),
        isNull,
      );

      final row = parseDoc(
        '<table><tr><th>名称</th><td>值1</td><td></td><td>值2</td></tr></table>',
      ).querySelector('tr')!;
      final (title, cells) = row.parseTableRow();
      expect(title, '名称');
      expect(cells, const ['值1', '值2']);

      final (noTitle, noCells) = parseDoc(
        '<table><tr><td>only</td></tr></table>',
      ).querySelector('tr')!.parseTableRow();
      expect(noTitle, isNull);
      expect(noCells, const ['only']);
    });

    test('reads the publish time of the supported date forms', () {
      final anchor = parseDoc(
        '<a id="a"><span title="2024-1-5 08:09:10">x</span></a>',
      ).querySelector('#a')!;
      expect(anchor.dateTime(), DateTime(2024, 1, 5, 8, 9, 10));

      final span = parseDoc(
        '<span id="s" title="2024-2-3 04:05:06">x</span>',
      ).querySelector('#s')!;
      expect(span.dateTime(), DateTime(2024, 2, 3, 4, 5, 6));

      final spanText = parseDoc(
        '<span id="s">2024-3-4 05:06:07</span>',
      ).querySelector('#s')!;
      expect(spanText.dateTime(), DateTime(2024, 3, 4, 5, 6, 7));

      // Nested span title form used by the post header.
      final nested = parseDoc(
        '<div id="d"><span title="2024-6-7 08:00:00">x</span></div>',
      ).querySelector('#d')!;
      expect(nested.dateTime(), DateTime(2024, 6, 7, 8));

      final posted = parseDoc(
        '<div id="p">发表于 2024-1-5 08:09:10</div>',
      ).querySelector('#p')!;
      expect(posted.dateTime(), DateTime(2024, 1, 5, 8, 9, 10));

      expect(
        parseDoc('<div id="n">no date here</div>').querySelector('#n')!.dateTime(),
        isNull,
      );
    });
  });

  group('tsdm model mapping', () {
    test('maps the notification json, users and login info', () {
      final notifications = TsdmNotificationV2.fromJson(<String, Object?>{
        'status': 1,
        'notification': [
          <String, Object?>{
            'id': 1,
            'timestamp': 100,
            'html': '<b>x</b>',
            'already_read': true,
          },
          <String, Object?>{'id': 2, 'timestamp': 50, 'html': '<i>y</i>'},
        ],
        'private_message': [
          <String, Object?>{
            'timestamp': 70,
            'message': 'hi',
            'peer_uid': 7,
            'peer_username': 'bob',
            'send': true,
            'read': true,
          },
        ],
        'public_message': [
          <String, Object?>{'timestamp': 30, 'preview': 'p', 'pmid': 9},
        ],
      });

      expect(notifications.status, 1);
      expect(notifications.noticeList, hasLength(2));
      expect(notifications.noticeList.first.alreadyRead, isTrue);
      expect(notifications.noticeList.last.alreadyRead, isFalse);
      expect(notifications.noticeList.last.data, '<i>y</i>');
      expect(notifications.personalMessageList.single.peerUsername, 'bob');
      expect(notifications.personalMessageList.single.peerUid, 7);
      expect(notifications.personalMessageList.single.sender, isTrue);
      expect(notifications.broadcastMessageList.single.data, 'p');
      expect(notifications.broadcastMessageList.single.pmid, 9);
      expect(
        notifications.latestTimestamp(),
        DateTime.fromMillisecondsSinceEpoch(100000),
      );

      // Missing mandatory fields are rejected, missing lists become empty.
      expect(
        TsdmNoticeV2.fromJson(<String, Object?>{'id': 1, 'timestamp': 1}),
        isNull,
      );
      expect(
        TsdmNoticeV2.fromJson(<String, Object?>{
          'id': 1,
          'timestamp': 1,
          'html': 2,
        }),
        isNull,
      );
      expect(
        TsdmPersonalMessageV2.fromJson(<String, Object?>{'timestamp': 1}),
        isNull,
      );
      expect(
        TsdmBroadcastMessageV2.fromJson(<String, Object?>{
          'timestamp': 1,
          'preview': 'p',
        }),
        isNull,
      );
      final empty = TsdmNotificationV2.fromJson(<String, Object?>{});
      expect(empty.status, 0);
      expect(empty.noticeList, isEmpty);
      expect(empty.latestTimestamp(), isNull);

      const user = TsdmUser(
        name: 'alice',
        url: 'https://www.tsdm39.com/home.php?mod=space&uid=42',
        uid: '42',
      );
      expect(user.isValid(), isTrue);
      expect(user.isNotValid(), isFalse);
      expect(const TsdmUser(name: '', url: 'x').isNotValid(), isTrue);
      expect(const TsdmUser(name: 'alice', url: '').isValid(), isFalse);

      const info = TsdmUserLoginInfo(username: 'alice', uid: 42);
      expect(info.isComplete, isTrue);
      expect(info.isEmpty, isFalse);
      expect(info.toString(), 'UserLoginInfo(username: ********, uid: ****)');
      expect(TsdmUserLoginInfo.empty().isComplete, isFalse);
      expect(const TsdmUserLoginInfo(username: 'alice').isComplete, isFalse);
      expect(const TsdmUserLoginInfo(uid: 42).isComplete, isFalse);
    });
  });

  group('TsdmPost parsing', () {
    test('parses a post node and skips invalid siblings', () {
      // The html package tests `:nth-child(n)` against the raw node index
      // (`parent.nodes.indexOf(element) == n`), text nodes included. This
      // fixture keeps the whitespace layout of a real page: one text node
      // before the row cells and none between them.
      const postHtml = '''
<div id="postlist">
  <div class="bm">
    <div id="post_123"><table><tbody>
<tr>
<td>
<div id="ts_avatar_123">
  <div>alice</div>
  <div class="avatar">
    <a href="home.php?mod=space&amp;uid=42"><img src="https://cdn.test/a.png"></a>
  </div>
</div>
</td><td>
<div id="authorposton123"><span title="2024-1-5 08:09:10">发表于</span></div>
<div class="pi"><strong><a href="forum.php?mod=redirect&amp;goto=findpost&amp;pid=123"><em>2</em></a></strong></div>
<div class="pcb"><b>hello</b></div>
</td>
</tr><tr>
<td class="tsdm_replybar"><div class="pob"><em><a href="forum.php?mod=post&amp;action=reply&amp;tid=1">回复</a></em></div></td>
</tr>
</tbody></table></div>
    <div id="post_999"></div>
    <div class="ad">ad</div>
  </div>
</div>
''';
      final document = parseDoc(postHtml);
      final posts = TsdmPost.buildListFromThreadDataNode(
        document.querySelector('#postlist'),
        3,
      );
      expect(posts, hasLength(1));

      final post = posts.single;
      expect(post.postID, '123');
      expect(post.postFloor, 2);
      expect(post.author.name, 'alice');
      expect(post.author.uid, '42');
      expect(post.author.url, 'https://www.tsdm39.com/home.php?mod=space&uid=42');
      expect(post.author.avatarUrl, 'https://cdn.test/a.png');
      expect(post.publishTime, DateTime(2024, 1, 5, 8, 9, 10));
      expect(post.data, '<b>hello</b>');
      expect(
        post.shareLink,
        'https://www.tsdm39.com/forum.php?mod=redirect&goto=findpost&pid=123',
      );
      expect(post.replyAction, 'forum.php?mod=post&action=reply&tid=1');
      expect(post.page, 3);
      expect(post.isDraft, isFalse);
      expect(post.hasPoll, isFalse);
      expect(post.locked, isEmpty);
      expect(post.rate, isNull);
      expect(post.packetUrl, isNull);
      expect(post.packetAllTaken, isFalse);
      expect(post.postMedals, isEmpty);

      // A node without an author is dropped, and a null root yields no posts.
      expect(
        TsdmPost.fromPostNode(document.querySelector('#post_999')!, 1),
        isNull,
      );
      expect(TsdmPost.buildListFromThreadDataNode(null, 1), isEmpty);
    });
  });

  group('TsdmSearchRepository parsing', () {
    test('reads the count, the page numbers and the result rows', () {
      // Same `:nth-child` node-index quirk as the post fixture.
      const searchHtml = '''
<html><body>
  <h3>12 条结果</h3>
  <div class="pg"><a href="?page=1">1</a><strong>1</strong></div>
  <div id="ct"><div id="ct_shell"><div id="left_s">
    <div class="ts_se_rs"><p><a href="https://www.tsdm39.com/forum.php?mod=viewthread&amp;tid=123">[动画] 标题</a></p><p><a href="https://www.tsdm39.com/home.php?mod=space&amp;uid=42">alice</a>
<span class="dateshow">时间2024-1-5 08:09:10</span>
<span class="fid"><a class="forum_l" href="https://www.tsdm39.com/forum-21-1.html">动画下载</a></span>
</p>
    </div>
    <div class="ts_se_rs"><p>broken row</p></div>
  </div></div></div>
</body></html>
''';
      final result = TsdmSearchRepository.parseSearchResultDocument(
        parseDoc(searchHtml),
      );
      expect(result.count, 12);
      expect(result.currentPage, 1);
      expect(result.totalPages, 1);
      expect(result.hasPreviousPage, isFalse);
      expect(result.hasNextPage, isFalse);
      expect(result.data, hasLength(1));

      final thread = result.data!.single;
      expect(thread.tid, 123);
      expect(thread.threadID, 123);
      expect(thread.title, '[动画] 标题');
      expect(thread.url, 'https://www.tsdm39.com/forum.php?mod=viewthread&tid=123');
      expect(thread.author.name, 'alice');
      expect(thread.author.url, 'https://www.tsdm39.com/home.php?mod=space&uid=42');
      expect(thread.forumName, '动画下载');
      expect(thread.forumUrl, 'https://www.tsdm39.com/forum-21-1.html');
      expect(thread.publishTime, DateTime(2024, 1, 5, 8, 9, 10));

      // An incomplete row is dropped, an empty page reports null data.
      const brokenHtml = '''
<div id="ct"><div id="ct_shell"><div id="left_s">
  <div class="ts_se_rs"><p><a href="https://x.test/1">t</a></p></div>
</div></div></div>
''';
      final broken = TsdmSearchRepository.parseSearchResultDocument(
        parseDoc(brokenHtml),
      );
      expect(broken.count, isNull);
      expect(broken.currentPage, 1);
      expect(broken.totalPages, 1);
      expect(broken.data, isNull);
    });
  });

  group('TsdmNotificationRepository', () {
    test('builds the mobile notification url inside a three day window', () {
      final fallback = TsdmNotificationRepository.buildNotificationV2Url();
      expect(fallback, startsWith(TsdmApiUrls.notificationV2UrlPrefix));
      final fallbackSeconds = int.parse(
        fallback.substring(TsdmApiUrls.notificationV2UrlPrefix.length),
      );
      final expectedSeconds =
          DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch ~/
              1000;
      expect((fallbackSeconds - expectedSeconds).abs(), lessThan(5));

      // A timestamp inside the window is used verbatim.
      final recent = DateTime.now().subtract(const Duration(hours: 1));
      expect(
        TsdmNotificationRepository.buildNotificationV2Url(timestamp: recent),
        '${TsdmApiUrls.notificationV2UrlPrefix}'
        '${recent.millisecondsSinceEpoch ~/ 1000}',
      );

      // Too old and future timestamps both fall back to the last three days.
      final stale = DateTime.now().subtract(const Duration(days: 5));
      final staleSeconds = int.parse(
        TsdmNotificationRepository.buildNotificationV2Url(timestamp: stale)
            .substring(TsdmApiUrls.notificationV2UrlPrefix.length),
      );
      expect((staleSeconds - expectedSeconds).abs(), lessThan(5));

      final future = DateTime.now().add(const Duration(days: 5));
      final futureSeconds = int.parse(
        TsdmNotificationRepository.buildNotificationV2Url(timestamp: future)
            .substring(TsdmApiUrls.notificationV2UrlPrefix.length),
      );
      expect(
        futureSeconds,
        lessThan(DateTime.now().millisecondsSinceEpoch ~/ 1000),
      );

      expect(TsdmNotificationRepository.canSync(const TsdmUserLoginInfo()), isFalse);
      expect(
        TsdmNotificationRepository.canSync(
          const TsdmUserLoginInfo(username: 'alice', uid: 42),
        ),
        isTrue,
      );
    });

    test('parses the notification json and reports the page parameter', () async {
      final client = TsdmHttpClient(
        cookieStore: TsdmCookieStore(),
        httpClient: MockClient((request) async {
          expect(request.url.queryParameters['mobile'], 'no');
          return http.Response(
            jsonEncode(<String, Object?>{
              'status': 1,
              'notification': [
                <String, Object?>{
                  'id': 5,
                  'timestamp': 1600000000,
                  'html': '<b>hi</b>',
                },
              ],
            }),
            200,
            headers: const {'content-type': 'application/json'},
            request: http.Request(
              'GET',
              Uri.parse('https://www.tsdm39.com/plugin.php?page=2'),
            ),
          );
        }),
      );

      final repository = TsdmNotificationRepository(client: client);
      final (notifications, page) = await repository.fetchNotificationV2(uid: 42);
      expect(page, '2');
      expect(notifications?.noticeList.single.id, 5);
      expect(notifications?.noticeList.single.timestamp, 1600000000);
      expect(notifications?.noticeList.single.data, '<b>hi</b>');
    });
  });
}
