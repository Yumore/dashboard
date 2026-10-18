import 'dart:convert';
import 'dart:math';

import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/htmanga_models.dart';
import 'package:dashboard/features/comic/picacomic/network/htmanga_parsing.dart';
import 'package:dashboard/features/comic/picacomic/network/network_result.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

/// 紳士漫畫 (wnacg) client, ported from
/// PicaComic lib/network/htmanga_network/htmanga_main_network.dart.
///
/// Deviations: the host has no `cookie_jar` / `dio_cookie_manager`, so session
/// cookies are kept in memory ([cookieHeader]) instead of a persistent jar; the
/// image/HTML response cache is likewise dropped.
class HtmangaNetwork {
  HtmangaNetwork({
    Dio? dio,
    String? baseUrl,
    Future<bool> Function()? reLogin,
  })  : dio = dio ?? createSourceDio(),
        baseUrl = baseUrl ?? defaultBaseUrl,
        _reLogin = reLogin;

  /// PicaComic defaults `appdata.settings[31]` to the https wnacg domain.
  static const String defaultBaseUrl = 'https://www.wnacg.com';

  final Dio dio;
  final String baseUrl;
  final Future<bool> Function()? _reLogin;

  final Map<String, String> _cookies = {};

  String get cookieHeader =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void _captureCookies(Response<dynamic> response) {
    final raw = response.headers['set-cookie'];
    if (raw == null) return;
    for (final value in raw) {
      final pair = value.split(';').first;
      final index = pair.indexOf('=');
      if (index <= 0) continue;
      _cookies[pair.substring(0, index)] = pair.substring(index + 1);
    }
  }

  Map<String, String> _headers({Map<String, String>? extra, bool post = false}) =>
      {
        'User-Agent': webUserAgent,
        if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        ...?extra,
        if (post)
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };

  /// Basic GET (htmanga_main_network.dart:33).
  ///
  /// A response landing on `users-login` means the session expired.
  Future<Res<String>> get(
    String url, {
    Map<String, String>? headers,
    bool cache = true,
  }) async {
    try {
      final response = await dio.get<String>(
        url,
        options: Options(headers: _headers(extra: headers)),
      );
      _captureCookies(response);
      if (response.realUri.toString().contains('users-login')) {
        return Res.error('未登录或登录到期');
      }
      return Res('${response.data}');
    } on DioException catch (e) {
      return Res.error(_message(e));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// Basic POST (htmanga_main_network.dart:63).
  Future<Res<String>> post(String url, String data) async {
    try {
      final response = await dio.post<String>(
        url,
        data: data,
        options: Options(headers: _headers(post: true)),
      );
      _captureCookies(response);
      if (response.realUri.toString().contains('users-login')) {
        return Res.error('未登录或登录到期');
      }
      return Res('${response.data}');
    } on DioException catch (e) {
      return Res.error(_message(e));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  static String _message(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '连接超时';
      default:
        return describeDioError(e);
    }
  }

  /// `POST users-check_login.html` with `login_name` / `login_pass`.
  Future<Res<bool>> login(String account, String pwd) async {
    final res = await post(
      '$baseUrl/users-check_login.html',
      'login_name=${Uri.encodeComponent(account)}'
      '&login_pass=${Uri.encodeComponent(pwd)}',
    );
    if (res.error) return Res.fromErrorRes(res);
    try {
      final json = jsonDecode(res.data) as Map<String, dynamic>;
      final html = '${json['html']}';
      if (html.contains('登錄成功')) return const Res(true);
      return Res.error(html);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  Future<Res<bool>> loginFromAppdata() async {
    final ok = await _reLogin?.call() ?? false;
    return ok ? const Res(true) : Res.error('error');
  }

  void logout() {
    _cookies.clear();
  }

  /// Home page: `div.title_sort` headings plus `div.bodywrap` comic blocks.
  Future<Res<HtHomePageData>> getHomePage() async {
    final res = await get(baseUrl, cache: false);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final titles = document.querySelectorAll('div.title_sort');
      final comicBlocks = document.querySelectorAll('div.bodywrap');
      final titleRes = <String, String>{};
      for (final title in titles) {
        final text = title
            .querySelector('div.title_h2')!
            .text
            .replaceAll('\n', '')
            .replaceAll(' ', '')
            .replaceAll('\t', '');
        final link = '$baseUrl${title.querySelector('div.r > a')!.attributes['href']}';
        titleRes[text] = link;
      }
      final comicsRes = <List<HtComicBrief>>[];
      for (final block in comicBlocks) {
        final comics = <HtComicBrief>[];
        for (final c in block.querySelectorAll('div.gallary_wrap > ul.cc > li')) {
          try {
            final link = c.querySelector('div.pic_box > a')!.attributes['href']!;
            final id = HtmangaParsing.aidFromLink(link)!;
            final image = HtmangaParsing.absoluteImage(
              c.querySelector('div.pic_box > a > img')!.attributes['src']!,
            );
            final name = c.querySelector('div.info > div.title > a')!.text;
            final infoCol = c.querySelector('div.info > div.info_col')!.text;
            final parts = infoCol.split(',');
            final pages = HtmangaParsing.pagesFromText(parts[1]) ?? 0;
            comics.add(HtComicBrief(name, parts[0], image, id, pages));
          } catch (_) {
            continue;
          }
        }
        comicsRes.add(comics);
      }
      if (comicsRes.length != titleRes.length) {
        throw Exception('漫画块数量和标题数量不相等');
      }
      return Res(HtHomePageData(comicsRes, titleRes));
    } catch (e) {
      return Res.error('解析失败: $e');
    }
  }

  /// A comic list page; [page] > 1 rewrites [url] through
  /// [HtmangaParsing.pageUrl]. `subData` is the page count.
  Future<Res<List<HtComicBrief>>> getComicList(
    String url,
    int page, {
    bool searchPage = false,
  }) async {
    url = HtmangaParsing.pageUrl(url, page);
    final res = await get(url, cache: false);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final comics = <HtComicBrief>[];
      for (final comic in document.querySelectorAll(
        'div.grid div.gallary_wrap > ul.cc > li',
      )) {
        try {
          final link = comic.querySelector('div.pic_box > a')!.attributes['href']!;
          final id = HtmangaParsing.aidFromLink(link)!;
          final image = HtmangaParsing.absoluteImage(
            comic.querySelector('div.pic_box > a > img')!.attributes['src']!,
          );
          final titleNode = comic.querySelector('div.info > div.title > a')!;
          final name = (titleNode.attributes['title'] ?? titleNode.text)
              .replaceAll('<em>', '')
              .replaceAll('</em>', '');
          final infoCol = comic.querySelector('div.info > div.info_col')!.text;
          final parts = infoCol.split('，');
          final time = parts[1].replaceAll(' ', '').replaceAll('\n', '').replaceAll('\t', '');
          final pages = HtmangaParsing.pagesFromText(parts[0]) ?? 0;
          comics.add(HtComicBrief(name, time, image, id, pages));
        } catch (_) {
          continue;
        }
      }
      int pages;
      try {
        if (searchPage) {
          final result = int.parse(
            HtmangaParsing.digitsOnly(
              document.querySelectorAll('p.result > b')[0].text,
            ),
          );
          final perPage = document.querySelectorAll(
            'div.grid div.gallary_wrap > ul.cc > li',
          ).length;
          pages = result ~/ perPage + 1;
        } else {
          final pagesLink = document.querySelectorAll('div.f_left.paginator > a');
          pages = int.parse(pagesLink.last.text);
        }
      } catch (_) {
        pages = 1;
      }
      return Res(comics, subData: pages);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `search/?q=<kw>&f=_all&s=create_time_DESC&syn=yes`
  Future<Res<List<HtComicBrief>>> search(String keyword, int page) => getComicList(
    '$baseUrl/search/?q=${Uri.encodeComponent(keyword)}'
    '&f=_all&s=create_time_DESC&syn=yes',
    page,
    searchPage: true,
  );

  /// `photos-index-page-1-aid-<id>.html`; `subData` carries the first page of
  /// thumbnails.
  Future<Res<HtComicInfo>> getComicInfo(String id) async {
    final res = await get('$baseUrl/photos-index-page-1-aid-$id.html', cache: false);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final name = document.querySelector('div.userwrap > h2')!.text;
      final coverPath = HtmangaParsing.normalizeCoverPath(
        document
            .querySelector('div.userwrap > div.asTB > div.asTBcell.uwthumb > img')!
            .attributes['src']!,
      );
      final labels = document.querySelectorAll('div.asTBcell.uwconn > label');
      final category = labels[0].text.split('：')[1];
      final pages = int.parse(
        RegExp(r'\d+').firstMatch(labels[1].text.split('：')[1])!.group(0)!,
      );
      final tags = <String, String>{};
      for (final tag in document.querySelectorAll('a.tagshow')) {
        tags[tag.text] = tag.attributes['href']!;
      }
      final description =
          document.querySelector('div.asTBcell.uwconn > p')!.text;
      final uploader =
          document.querySelector('div.asTBcell.uwuinfo > a > p')!.text;
      final avatar = '$baseUrl/'
          '${document.querySelector('div.asTBcell.uwuinfo > a > img')!.attributes['src']!}';
      final uploadNum = int.parse(
        document.querySelector('div.asTBcell.uwuinfo > p > font')!.text,
      );
      final photos = <String>[
        for (final img in document.querySelectorAll('div.pic_box.tb > a > img'))
          'https:${img.attributes['src']!}',
      ];
      return Res(
        HtComicInfo(
          id,
          coverPath,
          name,
          category,
          pages,
          tags,
          description,
          uploader,
          avatar,
          uploadNum,
          photos,
        ),
        subData: photos,
      );
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `photos-index-page-<page>-aid-<id>.html`
  Future<Res<List<String>>> getThumbnails(String id, int page) async {
    final res = await get('$baseUrl/photos-index-page-$page-aid-$id.html');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      return Res([
        for (final img in document.querySelectorAll('div.pic_box.tb > a > img'))
          'https:${img.attributes['src']!}',
      ]);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `photos-gallery-aid-<id>.html`; the reader image URLs are every
  /// `//host/path` token found in the page source.
  static final RegExp imageUrlPattern = RegExp(r'(?<=//)[\w./\[\]()-]+');

  Future<Res<List<String>>> getImages(String id) async {
    final res = await get('$baseUrl/photos-gallery-aid-$id.html');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final images = <String>[];
      for (final match in imageUrlPattern.allMatches(res.data)) {
        images.add('https://${match.group(0)!}');
      }
      return Res(images);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `users-addfav-id-210814.html` -> folder id -> folder name.
  Future<Res<Map<String, String>>> getFolders() async {
    final res = await get('$baseUrl/users-addfav-id-210814.html', cache: false);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final data = <String, String>{};
      for (final option in document.querySelectorAll('option')) {
        final value = option.attributes['value'];
        if (value == null || value.isEmpty) continue;
        data[value] = option.text;
      }
      return Res(data);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  Future<bool> createFolder(String name) async =>
      !(await post(
        '$baseUrl/users-favc_save-id.html',
        'favc_name=${Uri.encodeComponent(name)}',
      ))
          .error;

  Future<bool> deleteFolder(String id) async =>
      !(await get(
        '$baseUrl/users-favclass_del-id-$id.html'
        '?ajax=true&_t=${Random.secure().nextDouble()}',
        cache: false,
      ))
          .error;

  /// `POST users-save_fav-id-<comicId>.html` with `favc_id`.
  Future<Res<bool>> addFavorite(String comicId, String folderId) async {
    final res = await post(
      '$baseUrl/users-save_fav-id-$comicId.html',
      'favc_id=$folderId',
    );
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  /// `GET users-fav_del-id-<favoriteId>.html?ajax=true&_t=<random>`
  Future<Res<bool>> delFavorite(String favoriteId) async {
    final res = await get(
      '$baseUrl/users-fav_del-id-$favoriteId.html'
      '?ajax=true&_t=${Random.secure().nextDouble()}',
      cache: false,
    );
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  /// `users-users_fav-page-<page>-c-<folderId>.html`
  Future<Res<List<HtComicBrief>>> getFavoriteFolderComics(
    String folderId,
    int page,
  ) async {
    final res = await get(
      '$baseUrl/users-users_fav-page-$page-c-$folderId.html',
      cache: false,
    );
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final comics = <HtComicBrief>[];
      for (final comic in document.querySelectorAll('div.asTB')) {
        final cover = HtmangaParsing.absoluteImage(
          comic
              .querySelector('div.asTBcell.thumb > div > img')!
              .attributes['src']!,
        );
        final time = comic
            .querySelector('div.box_cel.u_listcon > p.l_catg > span')!
            .text
            .replaceAll('創建時間：', '');
        final titleLink = comic.querySelector(
          'div.box_cel.u_listcon > p.l_title > a',
        )!;
        final name = titleLink.text;
        final id = HtmangaParsing.aidFromLink(titleLink.attributes['href']!)!;
        final info =
            comic.querySelector('div.box_cel.u_listcon > p.l_detla')!.text;
        final pages = int.parse(
          RegExp(r'(?<=頁數：)[0-9]+').firstMatch(info)!.group(0)!,
        );
        final delUrl = comic
            .querySelector('div.box_cel.u_listcon > p.alopt > a')!
            .attributes['onclick']!;
        comics.add(
          HtComicBrief(
            name,
            time,
            cover,
            id,
            pages,
            favoriteId: HtmangaParsing.favoriteIdFromOnclick(delUrl),
          ),
        );
      }
      int pages;
      try {
        pages = int.parse(
          document.querySelectorAll('div.f_left.paginator > a').last.text,
        );
      } catch (_) {
        pages = page;
      }
      return Res(comics, subData: pages);
    } catch (e) {
      return Res.error(e.toString());
    }
  }
}
