import 'dart:convert';

import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/nhentai_models.dart';
import 'package:dashboard/features/comic/picacomic/network/nhentai_tags.dart';
import 'package:dashboard/features/comic/picacomic/network/parsing_utils.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

/// Ports PicaComic lib/network/nhentai_network/nhentai_main_network.dart.
///
/// Deviations:
/// * no `cookie_jar` / `dio_cookie_manager` / `CloudflareInterceptor` in the
///   host, so the `sessionid` cookie lives in [cookies] in memory and
///   [logged] is set/inspected through [logged] only;
/// * `appdata.searchHistory` writes are dropped (host search history is a
///   separate persistence layer);
/// * the "Uploaded" tag is stored as the raw `datetime` attribute instead of
///   the localized relative string from tools/time.dart (`timeToString`);
/// * `baseUrl` is injected instead of read from `appdata.settings[48]`.
class NhentaiNetwork {
  NhentaiNetwork({Dio? dio, String? baseUrl, this.logged = false})
      : dio = dio ?? createSourceDio(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  /// appdata.settings[48] default.
  static const String defaultBaseUrl = 'https://nhentai.net';

  final Dio dio;
  final String baseUrl;
  bool logged;

  final Map<String, String> cookies = {};

  String get cookieHeader =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  Map<String, String> _headers([Map<String, String>? extra]) => {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'zh-CN,zh-TW;q=0.9,zh;q=0.8,en-US;q=0.7,en;q=0.6',
    'Referer': '$baseUrl/',
    if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
    ...?extra,
  };

  void _captureCookies(Response<dynamic> response) {
    final raw = response.headers['set-cookie'];
    if (raw == null) return;
    for (final value in raw) {
      final pair = value.split(';').first;
      final index = pair.indexOf('=');
      if (index <= 0) continue;
      final name = pair.substring(0, index);
      cookies[name] = pair.substring(index + 1);
      if (name == 'sessionid') {
        logged = true;
      }
    }
  }

  /// nhentai_main_network.dart:61-76 — a 302 response returns the `Location`
  /// header (the site redirects `/g/<id>/` to the canonical gallery url).
  Future<Res<String>> get(String url) async {
    try {
      final res = await dio.get<String>(
        url,
        options: Options(
          headers: _headers(),
          validateStatus: (code) => code == 200 || code == 302,
          responseType: ResponseType.plain,
        ),
      );
      _captureCookies(res);
      if (res.statusCode == 302) {
        return Res(
          res.headers['Location']?.first ??
              res.headers['location']?.first ??
              '',
        );
      }
      return Res('${res.data}');
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  Future<Res<String>> post(
    String url,
    dynamic data, [
    Map<String, String>? headers,
  ]) async {
    try {
      final res = await dio.post<String>(
        url,
        data: data,
        options: Options(headers: _headers(headers)),
      );
      _captureCookies(res);
      return Res('${res.data}');
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// nhentai_main_network.dart:91-111 — `a > img[data-src]`,
  /// `div.caption`, the id digits of the `a[href]`, the language inferred from
  /// the gallery's `data-tags`, and the mapped tag names.
  NhentaiComicBrief parseComic(Element comicDom) {
    final img = comicDom.querySelector('a > img')!.attributes['data-src']!;
    final name = comicDom.querySelector('div.caption')!.text;
    final id = comicDom.querySelector('a')!.attributes['href']!.nums;
    var lang = 'Unknown';
    final tags = comicDom.attributes['data-tags'] ?? '';
    if (tags.contains('12227')) {
      lang = 'English';
    } else if (tags.contains('6346')) {
      lang = '日本語';
    } else if (tags.contains('29963')) {
      lang = '中文';
    }
    final tagsRes = <String>[];
    for (final tag in tags.split(' ')) {
      final name = nhentaiTags[tag];
      if (name != null) {
        tagsRes.add(name);
      }
    }
    return NhentaiComicBrief(name, img, id, lang, tagsRes);
  }

  /// nhentai_main_network.dart:118-149: `index-popular` is the "Popular" block
  /// and its galleries also appear in the generic list, hence the offset.
  Future<Res<NhentaiHomePageData>> getHomePage([int? page]) async {
    var url = baseUrl;
    if (page != null && page != 1) {
      url = '$url?page=$page';
    }
    final res = await get(url);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final popularDoms = url == baseUrl
          ? document.querySelectorAll(
              'div.container.index-container.index-popular > div.gallery',
            )
          : const <Element>[];
      final latest = document.querySelectorAll(
        'div.container.index-container > div.gallery',
      );
      return Res(
        NhentaiHomePageData(
          [
            for (final dom in popularDoms) parseComic(dom),
          ],
          [
            for (var i = popularDoms.length; i < latest.length; i++)
              parseComic(latest[i]),
          ],
        ),
      );
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  Future<Res<bool>> loadMoreHomePageData(NhentaiHomePageData data) async {
    final res = await get('$baseUrl?page=${data.page + 1}');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      for (final dom in document.querySelectorAll('div.gallery')) {
        data.latest.add(parseComic(dom));
      }
      data.page++;
      return const Res(true);
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  /// `search/?q=<kw>&page=<page><sort>`; `subData` is `ceil(resultCount / 25)`
  /// (25 galleries per page).
  Future<Res<List<NhentaiComicBrief>>> search(
    String keyword,
    int page, [
    NhentaiSort sort = NhentaiSort.recent,
  ]) async {
    final res = await get(
      '$baseUrl/search/?q=${Uri.encodeComponent(keyword)}'
      '&page=$page${sort.value}',
    );
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final comicDoms = document.querySelectorAll('div.gallery');
      final results = document.querySelector('div#content > h1')!.text;
      if (comicDoms.isEmpty) {
        return const Res([], subData: 0);
      }
      return Res(
        [
          for (final dom in comicDoms) parseComic(dom),
        ],
        subData: (int.parse(results.nums) / comicDoms.length).ceil(),
      );
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  /// nhentai_main_network.dart:214-297. An empty [id] hits `/random/` and
  /// reads the resolved id back out of `h3#gallery_id`.
  Future<Res<NhentaiComic>> getComicInfo(String id) async {
    final res = await get(id == '' ? '$baseUrl/random/' : '$baseUrl/g/$id/');
    if (res.error) return Res.fromErrorRes(res);
    try {
      String combineSpans(Element? title) {
        var text = '';
        for (final span in title?.children ?? const <Element>[]) {
          text += span.text;
        }
        return text;
      }

      final document = parse(res.data);
      id = id == '' ? document.querySelector('h3#gallery_id')!.text.nums : id;
      final cover =
          document.querySelector('div#cover > a > img')!.attributes['data-src']!;
      final title = combineSpans(document.querySelector('h1.title')!);
      final subTitle = combineSpans(document.querySelector('h2.title'));
      final tags = <String, List<String>>{};
      for (final field in document.querySelectorAll('div.tag-container')) {
        var fieldName = field.firstChild!.text!.removeAllBlank;
        if (fieldName.endsWith(':')) {
          fieldName = fieldName.substring(0, fieldName.length - 1);
        }
        if (fieldName == 'Uploaded') {
          final timeStr = document.querySelector('time')?.attributes['datetime'];
          if (timeStr != null) {
            tags['时间'] = [timeStr];
            continue;
          }
        }
        tags[fieldName] = [
          for (final span in field.querySelectorAll('span.name')) span.text,
        ];
      }
      final favorite =
          document.querySelector('button#favorite > span.text')?.text !=
                  'Favorite' &&
              logged;
      final thumbnails = <String>[
        for (final t in document.querySelectorAll('a.gallerythumb > img'))
          t.attributes['data-src']!,
      ];
      final recommendations = <NhentaiComicBrief>[
        for (final comic in document.querySelectorAll('div.gallery'))
          parseComic(comic),
      ];
      var token = '';
      try {
        final script = document
            .querySelectorAll('script')
            .firstWhere((element) => element.text.contains('csrf_token'))
            .text;
        token = script.split('csrf_token: "')[1].split('",')[0];
      } catch (_) {
        // A gallery page without an inlined csrf token stays anonymous.
      }
      return Res(
        NhentaiComic(
          id,
          title,
          subTitle,
          cover,
          tags,
          favorite,
          thumbnails,
          recommendations,
          token,
        ),
      );
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  Future<Res<List<NhentaiComment>>> getComments(String id) async {
    final res = await get('$baseUrl/api/gallery/$id/comments');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final json = const JsonDecoder().convert(res.data) as List<dynamic>;
      return Res([
        for (final c in json)
          NhentaiComment(
            c['poster']['username'] as String,
            'https://i3.nhentai.net/${c['poster']['avatar_url']}',
            c['body'] as String,
            c['post_date'] as int,
          ),
      ]);
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  /// nhentai_main_network.dart:321-388. `nhentai.net` embeds
  /// `window._gallery = JSON.parse("...")`; the `xxx` mirror lists `<img>`
  /// tags plus `span.num-pages`.
  Future<Res<List<String>>> getImages(String id) async {
    final res = await get('$baseUrl/g/$id/1/');
    if (res.error) return Res.fromErrorRes(res);
    try {
      if (baseUrl.contains('net')) {
        final document = parse(res.data);
        final script = document
            .querySelectorAll('script')
            .firstWhere((element) => element.text.contains('window._gallery'))
            .text;
        final jsonText = script.split('JSON.parse("')[1].split('");')[0];
        final decodedJsonText = jsonText
            .replaceAll(r'\u0022', '"')
            .replaceAll(r'\u005C', r'\');
        final galleryData =
            json.decode(decodedJsonText) as Map<String, dynamic>;
        final mediaId = galleryData['media_id'] as String;
        final images = <String>[];
        for (final image in galleryData['images']['pages'] as List<dynamic>) {
          final extension = switch (image['t']) {
            'j' => 'jpg',
            'p' => 'png',
            'g' => 'gif',
            _ => 'jpg',
          };
          images.add(
            'https://i7.nhentai.net/galleries/$mediaId/${images.length + 1}'
            '.$extension',
          );
        }
        return Res(images);
      } else if (baseUrl.contains('xxx')) {
        final document = parse(res.data);
        for (final element in document.querySelectorAll('img')) {
          final source =
              element.attributes['data-cfsrc'] ?? element.attributes['src'];
          if (source == null || source.contains('logo')) continue;
          final splits = source.split('/');
          final imageUrl = splits.sublist(0, splits.length - 1).join('/');
          final pages =
              int.parse(document.querySelector('span.num-pages')!.text);
          return Res([
            for (var i = 1; i <= pages; i++) '$imageUrl/$i.jpg',
          ]);
        }
        throw StateError('Failed to get images');
      } else {
        throw UnimplementedError();
      }
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  /// Favourites are 25 per page; `subData` is the last pagination number
  /// (nhentai_main_network.dart:391-414).
  Future<Res<List<NhentaiComicBrief>>> getFavorites(int page) async {
    if (!logged) {
      return Res.error('login required');
    }
    final res = await get('$baseUrl/favorites/?page=$page');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final comics = document.querySelectorAll('div.gallery');
      final lastPagination = document
          .querySelector('section.pagination > a.last')
          ?.attributes['href']
          ?.nums;
      return Res(
        [
          for (final comic in comics) parseComic(comic),
        ],
        subData: lastPagination == null ? 1 : int.parse(lastPagination),
      );
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }

  Future<Res<bool>> favoriteComic(String id, String token) async {
    final res = await post('$baseUrl/api/gallery/$id/favorite', null, {
      'Referer': '$baseUrl/g/$id',
      'X-Csrftoken': token,
      'X-Requested-With': 'XMLHttpRequest',
    });
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  Future<Res<bool>> unfavoriteComic(String id, String token) async {
    final res = await post('$baseUrl/api/gallery/$id/unfavorite', null, {
      'Referer': '$baseUrl/g/$id',
      'X-Csrftoken': token,
      'X-Requested-With': 'XMLHttpRequest',
    });
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  /// nhentai_main_network.dart:442-482 — `/language/<name><sort>?page=<page>`.
  Future<Res<List<NhentaiComicBrief>>> getCategoryComics(
    String path,
    int page,
    NhentaiSort sort,
  ) async {
    final param = switch (sort) {
      NhentaiSort.recent => '/',
      NhentaiSort.popularToday => '/popular-today',
      NhentaiSort.popularWeek => '/popular-week',
      NhentaiSort.popularMonth => '/popular-month',
      NhentaiSort.popularAll => '/popular',
    };
    final res = await get('$baseUrl$path$param?page=$page');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final comicDoms = document.querySelectorAll('div.gallery');
      final results = document.querySelector('div#content > h1')!.text;
      if (comicDoms.isEmpty) {
        return const Res([], subData: 0);
      }
      return Res(
        [
          for (final dom in comicDoms) parseComic(dom),
        ],
        subData: (int.parse(results.nums) / comicDoms.length).ceil(),
      );
    } catch (e) {
      return Res.error('Failed to Parse Data: $e');
    }
  }
}
