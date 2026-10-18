import 'dart:async';

import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/eh_models.dart';
import 'package:dashboard/features/comic/picacomic/network/network_result.dart';
import 'package:dashboard/features/comic/picacomic/network/parsing_utils.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';
import 'package:dio/dio.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Ports lib/network/eh_network/eh_main_network.dart.
///
/// Deviations (all reported): the singleton + `cookieJar` global are replaced by
/// a constructor taking an injected [Dio] and a cookie provider, because the
/// host has no `cookie_jar` dependency. Cache/log plumbing is dropped.
class EhNetwork {
  EhNetwork({
    Dio? dio,
    String Function()? cookieProvider,
    this.exhentai = false,
    void Function(List<String> folders)? onFolderNames,
  })  : dio = dio ?? createSourceDio(),
        _cookieProvider = cookieProvider,
        _onFolderNames = onFolderNames,
        folderNames = List.generate(10, (index) => 'Favorite $index');

  final Dio dio;
  final String Function()? _cookieProvider;
  final bool exhentai;
  final void Function(List<String> folders)? _onFolderNames;

  /// Ports `folderNames`: the ten e-hentai favourite folder display names.
  List<String> folderNames;

  final Set<String> _loadingReaderLinks = {};

  /// `ehBaseUrl`: setting [20] selects exhentai.
  String get baseUrl =>
      exhentai ? 'https://exhentai.org' : 'https://e-hentai.org';

  /// `ehApiUrl`.
  String get apiUrl => exhentai
      ? 'https://exhentai.org/api.php'
      : 'https://api.e-hentai.org/api.php';

  String get cookiesStr => _cookieProvider?.call() ?? '';

  Map<String, String> get requestHeaders => {
        'Cookie': cookiesStr,
        'User-Agent': webUserAgent,
        'Referer': baseUrl,
      };

  Future<Res<String>> request(String url, {Map<String, String>? headers}) {
    return guardRequest(() async {
      final response = await dio.get<String>(
        url,
        options: Options(headers: {...requestHeaders, ...?headers}),
      );
      return response.data ?? '';
    });
  }

  Future<Res<String>> post(
    String url,
    String data, {
    Map<String, String>? headers,
  }) {
    return guardRequest(() async {
      final response = await dio.post<String>(
        url,
        data: data,
        options: Options(headers: {...requestHeaders, ...?headers}),
      );
      return response.data ?? '';
    });
  }

  // ---------------------------------------------------------------- listings

  /// Ports `getGalleries`. Handles the four e-hentai list layouts and reads the
  /// `#dnext` next-page link. When [favoritePage] is set the favourite folder
  /// names discovered on the page are returned through [Res.subData] and pushed
  /// to [onFolderNames].
  Future<Res<EhGalleries>> getGalleries(
    String url, {
    bool leaderboard = false,
    bool favoritePage = false,
  }) async {
    final offset = leaderboard ? 1 : 0;
    final res = await request(url);
    if (res.error) {
      return Res(null, errorMessage: res.errorMessage);
    }
    try {
      final document = html_parser.parse(res.data);
      final galleries = <EhGalleryBrief>[];

      // compact mode: table.itg.gltc
      for (final item
          in document.querySelectorAll('table.itg.gltc > tbody > tr')) {
        try {
          final type = item.children[0 + offset].children[0].text;
          final time =
              item.children[1 + offset].children[2].children[0].text;
          final stars = getStarsFromPosition(item
              .children[1 + offset].children[2].children[1]
              .attributes['style']!);
          var cover = item.children[1 + offset].children[1].children[0]
              .children[0].attributes['src'];
          if (cover != null && cover.startsWith('d')) {
            cover = item.children[1 + offset].children[1].children[0]
                .children[0].attributes['data-src'];
          }
          final title = item.children[2 + offset].children[0].children[0].text;
          final link =
              item.children[2 + offset].children[0].attributes['href'];
          var uploader = '';
          int? pages;
          try {
            uploader = item.children[3 + offset].children[0].children[0].text;
            pages = int.parse(item.children[3 + offset].children[1].text.nums);
          } catch (_) {
            // favourite pages have no uploader column
          }
          final tags = <String>[];
          for (final node in item.children[2 + offset].children[0]
              .children[1].children) {
            tags.add(node.attributes['title']!);
          }
          galleries.add(EhGalleryBrief(title, type, time, uploader, cover!,
              stars, link!, tags,
              pages: pages));
        } catch (_) {
          // blank rows / blocked works
          continue;
        }
      }

      // thumbnail mode: div.gl1t
      for (final item in document.querySelectorAll('div.gl1t')) {
        try {
          final title = item.querySelector('a')?.text ?? 'Unknown';
          final type = item.querySelector('div.gl5t > div > div.cs')?.text ??
              'Unknown';
          final time = item
                  .querySelectorAll('div.gl5t > div > div')
                  .firstWhereOrNull(
                      (element) => DateTime.tryParse(element.text) != null)
                  ?.text ??
              'Unknown';
          final coverPath =
              item.querySelector('img')?.attributes['src'] ?? '';
          final stars = getStarsFromPosition(
              item.querySelector('div.gl5t > div > div.ir')?.attributes['style'] ??
                  '');
          final link = item.querySelector('a')?.attributes['href'] ?? '';
          final pages = int.tryParse(item
                  .querySelectorAll('div.gl5t > div > div')
                  .firstWhereOrNull(
                      (element) => element.text.contains('pages'))
                  ?.text
                  .nums ??
              '');
          galleries.add(EhGalleryBrief(
              title, type, time, '', coverPath, stars, link, [],
              pages: pages));
        } catch (_) {
          // ignore
        }
      }

      // extended mode: table.itg.glte
      for (final item
          in document.querySelectorAll('table.itg.glte > tbody > tr')) {
        try {
          final title = item
                  .querySelector('td.gl2e > div > a > div > div.glink')
                  ?.text ??
              'Unknown';
          final type =
              item.querySelector('td.gl2e > div > div.gl3e > div.cn')?.text ??
                  'Unknown';
          final time = item
                  .querySelectorAll('td.gl2e > div > div.gl3e > div')
                  .firstWhereOrNull(
                      (element) => DateTime.tryParse(element.text) != null)
                  ?.text ??
              'Unknown';
          final uploader =
              item.querySelector('td.gl2e > div > div.gl3e > div > a')?.text ??
                  'Unknown';
          final coverPath =
              item.querySelector('td.gl1e > div > a > img')?.attributes['src'] ??
                  '';
          final stars = getStarsFromPosition(item
                  .querySelector('td.gl2e > div > div.gl3e > div.ir')
                  ?.attributes['style'] ??
              '');
          final link =
              item.querySelector('td.gl1e > div > a')?.attributes['href'] ??
                  '';
          final tags = item
              .querySelectorAll('div.gtl')
              .map((element) => element.attributes['title'] ?? '')
              .toList();
          final pages = int.tryParse(item
                  .querySelectorAll('td.gl2e > div > div.gl3e > div')
                  .firstWhereOrNull(
                      (element) => element.text.contains('pages'))
                  ?.text
                  .nums ??
              '');
          galleries.add(EhGalleryBrief(
              title, type, time, uploader, coverPath, stars, link, tags,
              pages: pages));
        } catch (_) {
          // ignore
        }
      }

      // minimal mode: table.itg.gltm
      for (final item
          in document.querySelectorAll('table.itg.gltm > tbody > tr')) {
        try {
          final title = item.querySelector('td.gl3m > a > div.glink')?.text ??
              'Unknown';
          final type = item.querySelector('td.gl1m > div.cs')?.text ?? 'Unknown';
          final time = item
                  .querySelectorAll('td.gl2m > div')
                  .firstWhereOrNull(
                      (element) => DateTime.tryParse(element.text) != null)
                  ?.text ??
              'Unknown';
          final uploader =
              item.querySelector('td.gl5m > div > a')?.text ?? 'Unknown';
          final coverPath =
              item.querySelector('td.gl2m > div > div > img')?.attributes['src'] ??
                  '';
          final stars = getStarsFromPosition(
              item.querySelector('td.gl4m > div.ir')?.attributes['style'] ?? '');
          final link = item.querySelector('td.gl3m > a')?.attributes['href'] ?? '';
          galleries.add(EhGalleryBrief(
              title, type, time, uploader, coverPath, stars, link, []));
        } catch (_) {
          // ignore
        }
      }

      final result = EhGalleries(galleries);
      result.next = document.getElementById('dnext')?.attributes['href'];

      if (favoritePage) {
        var names = <String>[];
        try {
          final folderDivs = document.querySelectorAll('div.fp');
          for (final folderDiv in folderDivs) {
            final name = folderDiv.children.atOrNull(2)?.text ??
                'Favorite ${names.length}';
            var length = folderDiv.children.atOrNull(0)?.text;
            if (length != null) length = ' ($length)';
            length ??= '';
            names.add('$name$length');
          }
          if (names.length != 10 && names.length > 10) {
            names = names.sublist(0, 10);
          }
          if (names.length == 10 && !_sameList(folderNames, names)) {
            folderNames = names;
            _onFolderNames?.call(names);
          }
        } catch (_) {
          // ignore
        }
        return Res(result, subData: folderNames);
      }
      return Res(result);
    } catch (e) {
      return Res(null, errorMessage: e.toString());
    }
  }

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Ports `getNextPageGalleries`.
  Future<bool> getNextPageGalleries(EhGalleries galleries) async {
    final next = galleries.next;
    if (next == null) return true;
    final res = await getGalleries(next);
    if (res.error) return false;
    galleries.galleries.addAll(res.data.galleries);
    galleries.next = res.data.next;
    return true;
  }

  // ------------------------------------------------------------------ detail

  EhComment parseComment(dom.Element element) {
    final name = element
            .getElementsByClassName('c3')
            .atOrNull(0)
            ?.getElementsByTagName('a')
            .atOrNull(0)
            ?.text ??
        '未知';
    final time = element
            .getElementsByClassName('c3')
            .atOrNull(0)
            ?.text
            .split('Posted on')
            .atOrNull(1)
            ?.split('by')
            .atOrNull(0)
            ?.trim() ??
        'unknown';
    final content = element.getElementsByClassName('c6')[0].text;
    final score = int.parse(element.querySelector('div.c5 > span')?.text ?? '0');
    final id = element.previousElementSibling?.attributes['name']?.nums ?? '0';
    final voteUp = element
            .querySelector('a#comment_vote_up_$id')
            ?.attributes['style']
            ?.isNotEmpty ==
        true;
    final voteDown = element
            .querySelector('a#comment_vote_down_$id')
            ?.attributes['style']
            ?.isNotEmpty ==
        true;
    bool? vote;
    if (voteUp) {
      vote = true;
    } else if (voteDown) {
      vote = false;
    }
    return EhComment(id, name, content, time, score, vote);
  }

  /// Ports `getGalleryInfo`.
  Future<Res<EhGallery>> getGalleryInfo(String link) async {
    try {
      final res = await request(link);
      if (res.error) {
        return Res(null, errorMessage: res.errorMessage);
      }
      if (res.data.contains('Content Warning') &&
          res.data.contains('Never Warn Me Again')) {
        return const Res(null, errorMessage: 'Content Warning');
      }
      final document = html_parser.parse(res.data);

      final tags = <String, List<String>>{};
      for (final tr in document
          .querySelectorAll('div#taglist > table > tbody > tr')) {
        if (tr.children.length < 2) continue;
        final list = <String>[];
        for (final div in tr.children[1].children) {
          // 源页面每个标签外层可能带也可能不带一层包裹元素，直接取文本对两种
          // 结构都成立（原来固定取 children[0].text，裸 `<a>` 结构会抛 RangeError）。
          final text = div.text.trim();
          if (text.isNotEmpty) list.add(text);
        }
        final namespace = tr.children[0].text.trim();
        if (namespace.isEmpty) continue;
        final key = namespace.endsWith(':')
            ? namespace.substring(0, namespace.length - 1)
            : namespace;
        tags[key] = list;
      }

      var maxPage = 1;
      for (final element in document.querySelectorAll('td.gdt2')) {
        if (element.text.contains('pages')) {
          maxPage = int.tryParse(element.text.nums) ?? 1;
        }
      }

      final favorite = document.getElementById('favoritelink')?.text !=
          ' Add to Favorites';

      var coverPath =
          document.querySelector('div#gleft > div#gd1 > div')!.attributes['style']!;
      coverPath = RegExp(r'https?://([-a-zA-Z0-9.]+(/\S*)?\.(?:jpg|jpeg|gif|png))')
          .firstMatch(coverPath)![0]!;

      final comments = <EhComment>[];
      for (final element in document.getElementsByClassName('c1')) {
        comments.add(parseComment(element));
      }

      final uploader =
          document.getElementById('gdn')!.children.atOrNull(0)?.text ?? '未知';
      final stars = getStarsFromPosition(
          document.getElementById('rating_image')!.attributes['style']!);
      final rating = document.getElementById('rating_label')?.text;
      final type = document.getElementsByClassName('cs')[0].text;
      final time = document
          .querySelector('div#gdd > table > tbody > tr > td.gdt2')!
          .text;

      final auth = parseJsVariables(res.data);
      final thumbnailUrls = <String>[];
      final title = document.querySelector('h1#gn')!.text;
      var subTitle = document.querySelector('h1#gj')?.text;
      if (subTitle != null && subTitle.removeAllBlank == '') {
        subTitle = null;
      }

      final thumbnailDiv =
          document.querySelectorAll('div.gdtm > div').atOrNull(0);
      if (thumbnailDiv != null) {
        final key = extractThumbnailKey(thumbnailDiv.attributes['style'] ?? '');
        if (key != null) auth['thumbnailKey'] = key;
      } else {
        for (final img in document.querySelectorAll('div.gdtl > a > img')) {
          final src = img.attributes['src'];
          if (src != null) thumbnailUrls.add(src);
        }
        final totalPages = document
            .querySelectorAll('table.ptt > tbody > tr > td > a')
            .firstWhereOrNull((element) => element.text.isNum)
            ?.text;
        auth['thumbnailKey'] = 'large thumbnail: $totalPages';
      }

      var archiveDownload = document
          .querySelectorAll('a')
          .firstWhereOrNull((element) => element.text == 'Archive Download')
          ?.attributes['onclick'];
      if (archiveDownload != null) {
        archiveDownload = archiveDownload.split("'")[1];
        if (archiveDownload.isURL) {
          auth['archiveDownload'] = archiveDownload;
        }
      }

      return Res(EhGallery(
        title: title,
        subTitle: subTitle,
        type: type,
        time: time,
        uploader: uploader,
        stars: stars,
        rating: rating,
        coverPath: coverPath,
        tags: tags,
        comments: comments,
        auth: auth,
        favorite: favorite,
        link: link,
        maxPage: maxPage,
        thumbnails: thumbnailUrls,
      ));
    } catch (e) {
      return Res(null, errorMessage: e.toString());
    }
  }

  /// Ports the `div.gdtm` thumbnail-key extraction.
  ///
  /// Deviation: the original stored only the `/m/(\d+)/` digits, which cannot
  /// form a URL; the `url(...)` form is preferred here (it is what
  /// `getThumbnailUrls` falls back to) and the digit form is kept as fallback.
  static String? extractThumbnailKey(String style) {
    final urlMatch = RegExp(r'url\((.*?)\)').firstMatch(style);
    if (urlMatch != null) {
      final url = urlMatch.group(1)!;
      final lastSlash = url.lastIndexOf('/');
      if (lastSlash != -1) return url.substring(0, lastSlash);
      return url;
    }
    final folderMatch = RegExp(r'/m/(\d+)/').firstMatch(style);
    if (folderMatch != null) return folderMatch.group(1);
    return null;
  }

  /// Ports `getComments`.
  Future<Res<List<EhComment>>> getComments(String url) async {
    final res = await request('$url?hc=1');
    if (res.error) {
      return Res(null, errorMessage: res.errorMessage);
    }
    try {
      final document = html_parser.parse(res.data);
      final comments = <EhComment>[];
      for (final element in document.getElementsByClassName('c1')) {
        comments.add(parseComment(element));
      }
      return Res(comments);
    } catch (e) {
      return Res(null, errorMessage: e.toString());
    }
  }

  // ------------------------------------------------------------------ reader

  /// Ports `getReaderLink`. [page] starts at 1.
  Future<Res<String>> getReaderLink(String galleryLink, int page) async {
    final res = await getReaderLinks(galleryLink, 1);
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    final urlsOnePage = res.data.length;
    if (urlsOnePage == 0) {
      return const Res(null, errorMessage: 'No image links found');
    }
    if (page <= urlsOnePage) {
      return Res(res.data[page - 1]);
    }
    final shouldLoadPage = (page - 1) ~/ urlsOnePage + 1;
    final urlsRes = await getReaderLinks(galleryLink, shouldLoadPage);
    if (urlsRes.error) {
      return Res.fromErrorRes(urlsRes);
    }
    return Res(urlsRes.data[(page - 1) % urlsOnePage]);
  }

  /// Ports `_getReaderLinks`. [page] starts at 1; e-hentai's own `p` query
  /// parameter is zero based.
  Future<Res<List<String>>> getReaderLinks(String link, int page) async {
    var url = link;
    if (page != 1) {
      url = url.contains('?') ? '$url&p=${page - 1}' : '$url?p=${page - 1}';
    }
    while (_loadingReaderLinks.contains(url)) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
    _loadingReaderLinks.add(url);
    final res = await request(url);
    _loadingReaderLinks.remove(url);
    if (res.error) {
      return Res(null, errorMessage: res.errorMessage);
    }
    try {
      final urls = <String>[];
      final document = html_parser.parse(res.data);
      for (final element
          in document.querySelectorAll('div#gdt > div.gdtm > div > a')) {
        final href = element.attributes['href'];
        if (href != null) urls.add(href);
      }
      for (final element
          in document.querySelectorAll('div#gdt > div.gdtl > a')) {
        final href = element.attributes['href'];
        if (href != null) urls.add(href);
      }
      return Res(urls);
    } catch (e) {
      return Res(null, errorMessage: e.toString());
    }
  }

  /// Ports `getImageLinkWithNL`, but takes the reader page link instead of the
  /// three scraped parts.
  Future<Res<String>> getImageUrl(String readerLink) async {
    final parsed = parseReaderLink(readerLink);
    if (parsed == null) {
      return const Res(null, errorMessage: 'Invalid reader link');
    }
    return getImageLinkWithNl(parsed.gid, parsed.imgKey, parsed.page, '');
  }

  /// Ports the `$ehBaseUrl/s/$imgKey/$gid-$p?nl=$nl` image-page request.
  Future<Res<String>> getImageLinkWithNl(
    String gid,
    String imgKey,
    int page,
    String nl,
  ) async {
    final res = await request('$baseUrl/s/$imgKey/$gid-$page?nl=$nl');
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    final document = html_parser.parse(res.data);
    final image = document.querySelector('div#i3 > a > img')?.attributes['src'];
    if (image == null) {
      return const Res(null, errorMessage: 'Failed to get image.');
    }
    return Res(image);
  }

  /// Splits `/s/<imgKey>/<gid>-<page>` out of a reader link.
  static EhReaderLink? parseReaderLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    final sIndex = segments.indexOf('s');
    if (sIndex == -1 || sIndex + 2 >= segments.length) return null;
    final imgKey = segments[sIndex + 1];
    final match = RegExp(r'^(\d+)-(\d+)$').firstMatch(segments[sIndex + 2]);
    if (match == null) return null;
    return EhReaderLink(
      imgKey: imgKey,
      gid: match.group(1)!,
      page: int.parse(match.group(2)!),
    );
  }

  /// Ports `getThumbnailUrls`.
  Future<Res<List<String>>> getThumbnailUrls(EhGallery gallery) async {
    if (gallery.auth?['thumbnailKey'] == null) {
      final res = await request(gallery.link);
      if (res.error) {
        return Res.fromErrorRes(res);
      }
      final document = html_parser.parse(res.data);
      final thumbnailDiv = document.querySelectorAll('div.gdtm > div').atOrNull(0);
      final key = thumbnailDiv == null
          ? null
          : extractThumbnailKey(thumbnailDiv.attributes['style'] ?? '');
      if (key == null) {
        return const Res(null, errorMessage: 'Failed to get Thumbnail');
      }
      gallery.auth?['thumbnailKey'] = key;
    }
    final key = gallery.auth!['thumbnailKey']!;
    return Res(List.generate(gallery.maxPage, (index) {
      var page = (index ~/ 20).toString();
      if (page.length == 1) page = '0$page';
      return '$key/${getGalleryId(gallery.link)}-$page.jpg';
    }));
  }

  /// Ports `getLargeThumbnails`.
  Future<Res<List<String>>> getLargeThumbnails(
      EhGallery gallery, int page) async {
    final res = await request('${gallery.link}?p=$page');
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    final document = html_parser.parse(res.data);
    return Res(document
        .querySelectorAll('div.gdtl > a > img')
        .map((element) => element.attributes['src'] ?? '')
        .toList());
  }

  // ------------------------------------------------------------------ search

  /// Ports `_splitKeyword`: splits on spaces but keeps quoted runs together.
  static List<String> splitKeyword(String keyword) {
    final result = <String>[];
    final buffer = StringBuffer();
    final quotes = <String>[];
    for (var i = 0; i < keyword.length; i++) {
      final char = keyword[i];
      if (char == '"' || char == "'") {
        if (quotes.isEmpty) {
          quotes.add(char);
        } else if (quotes.first == char) {
          quotes.removeAt(0);
        } else {
          quotes.add(char);
        }
      }
      if (char == ' ') {
        if (quotes.isEmpty) {
          result.add(buffer.toString());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      } else {
        buffer.write(char);
      }
    }
    if (buffer.isNotEmpty) result.add(buffer.toString());
    return result;
  }

  /// Ports `search`. Returns the request URL through [Res.subData] so callers
  /// (and tests) can assert the exact query string.
  Future<Res<EhGalleries>> search(
    String keyword, {
    int? fCats,
    int? startPages,
    int? endPages,
    int? minStars,
  }) async {
    final normalized = normalizeKeyword(keyword);
    var requestUrl =
        '$baseUrl/?f_search=${Uri.encodeQueryComponent(normalized)}';
    if (fCats != null) requestUrl += '&f_cats=$fCats';
    if (startPages != null) requestUrl += '&f_spf=$startPages';
    if (endPages != null) requestUrl += '&f_spt=$endPages';
    if (minStars != null) requestUrl += '&f_srdd=$minStars';
    final res = await getGalleries(requestUrl);
    if (res.error) return res;
    return Res(res.data, subData: requestUrl);
  }

  /// Ports the ` | ` OR-query normalisation of `search`.
  static String normalizeKeyword(String keyword) {
    var result = keyword.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (result.contains(' | ')) {
      final parts = splitKeyword(result);
      final newParts = <String>[];
      for (final part in parts) {
        if (!part.contains(' | ')) {
          newParts.add(part);
        } else {
          final lr = part.split(':');
          if (lr.length != 2) {
            newParts.add(part);
          } else {
            final value = lr[1].startsWith('"') && lr[1].endsWith('"');
            final value2 = lr[1].startsWith("'") && lr[1].endsWith("'");
            if (!value && !value2) {
              newParts.add(part);
            } else {
              final key = lr[0];
              final inner = lr[1].substring(1, lr[1].length - 1);
              final first = inner.split(' | ').first;
              newParts.add('$key:"$first\$"');
            }
          }
        }
      }
      result = newParts.join(' ');
    }
    return result;
  }

  /// Ports `getLeaderBoardByPage`.
  Future<Res<List<BaseComic>>> getLeaderBoardByPage(int type, int page) async {
    final res = await getGalleries(
      'https://e-hentai.org/toplist.php?tl=$type&p=$page',
      leaderboard: true,
    );
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(res.data.galleries, subData: 200);
  }

  /// Ports `getLeaderboard`.
  Future<Res<EhLeaderboard>> getLeaderboard(EhLeaderboardType type) async {
    final res = await getGalleries(
      'https://e-hentai.org/toplist.php?tl=${type.value}',
      leaderboard: true,
    );
    if (res.error) return Res(null, errorMessage: res.errorMessage);
    return Res(EhLeaderboard(type, res.data.galleries, 0));
  }

  // --------------------------------------------------------------- favourites

  /// Ports `favorite`.
  Future<bool> favorite(String gid, String token, {String id = '0'}) async {
    final res = await post(
      'https://e-hentai.org/gallerypopups.php?gid=$gid&t=$token&act=addfav',
      'favcat=$id&favnote=&apply=Add+to+Favorites&update=1',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    if (res.error || res.data.isEmpty || res.data[0] != '<') return false;
    return true;
  }

  /// Ports `unfavorite`.
  Future<bool> unfavorite(String gid, String token) async {
    final res = await post(
      'https://e-hentai.org/gallerypopups.php?gid=$gid&t=$token&act=addfav',
      'favcat=favdel&favnote=&apply=Apply+Changes&update=1',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    if (res.error || res.data.isEmpty || res.data[0] != '<') return false;
    return true;
  }

  /// Ports `unfavorite2`.
  Future<bool> unfavorite2(String gid) async {
    final res = await post(
      'https://e-hentai.org/favorites.php',
      'ddact=delete&modifygids%5B%5D=$gid',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    return !res.error;
  }

  /// Ports `comment`.
  Future<Res<bool>> comment(String content, String link) async {
    final res = await post(
      link,
      'commenttext_new=${Uri.encodeComponent(content)}',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );
    if (res.error) {
      return Res(null, errorMessage: res.errorMessage);
    }
    final document = html_parser.parse(res.data);
    final error = document.querySelector('p.br');
    if (error != null) {
      return Res(null, errorMessage: error.text);
    }
    return const Res(true);
  }
}

/// Result of [EhNetwork.parseReaderLink].
class EhReaderLink {
  const EhReaderLink({
    required this.imgKey,
    required this.gid,
    required this.page,
  });

  final String imgKey;
  final String gid;
  final int page;
}
