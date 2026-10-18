import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_aes.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_comics_order.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_headers.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_image_urls.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_models.dart';
import 'package:dashboard/features/comic/picacomic/network/jm_week_recommendation_type.dart';
import 'package:dashboard/features/comic/picacomic/network/network_result.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parseFragment;

/// 禁漫天堂 (18comic) client, ported from
/// PicaComic lib/network/jm_network/jm_network.dart.
///
/// Deviations: PicaComic persisted a `CookieJar` and a response cache; this port
/// keeps the handful of session cookies in memory ([cookieHeader]) and relies on
/// the caller for caching. The rotating CDN host list is used as a constant
/// ([defaultBaseUrl]) because the host has no `appdata.settings` store.
class JmNetwork {
  JmNetwork({
    Dio? dio,
    String? baseUrl,
    int Function()? clock,
    Future<bool> Function()? reLogin,
  })  : dio = dio ?? createSourceDio(),
        baseUrl = baseUrl ?? defaultBaseUrl,
        _clock = clock ?? _nowSeconds,
        _reLogin = reLogin;

  static const List<String> baseUrls = [
    'https://www.jmeadpoolcdn.one',
    'https://www.jmeadpoolcdn.life',
    'https://www.jmapiproxyxxx.one',
    'https://www.jmfreedomproxy.xyz',
  ];

  static const String defaultBaseUrl = 'https://www.jmeadpoolcdn.one';

  /// `md5("<time>$kJmSecret")` is the AES key for every response body.
  static const String kJmSecret = '185Hcomic3PAPP7R';

  final Dio dio;
  final String baseUrl;
  final Future<bool> Function()? _reLogin;
  final int Function() _clock;

  final Map<String, String> _cookies = {};
  final String _device = JmHeaderBuilder.deviceId();

  /// Filled by [getHotTags].
  var hotTags = <String>[];

  static int _nowSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// `key=value; key=value` for the current session, or an empty string.
  String get cookieHeader =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  /// Decrypts a base64 AES-ECB response body.
  ///
  /// Key = utf8(md5("<time>$kJmSecret")) (32 bytes -> AES-256), body = AES-ECB
  /// ciphertext, and the plaintext is cut back to the last `}` or `]` because
  /// PKCS#7 padding is left in place.
  static String convertData(String input, int time) {
    final key = utf8.encode(
      md5.convert(utf8.encode('$time$kJmSecret')).toString(),
    );
    final plainBytes = JmAesEcb(key).decrypt(base64Decode(input));
    final res = utf8.decode(plainBytes, allowMalformed: true);
    var i = res.length - 1;
    for (; i >= 0; i--) {
      if (res[i] == '}' || res[i] == ']') break;
    }
    return res.substring(0, i + 1);
  }

  Options _options(Map<String, String> headers) => Options(
    responseType: ResponseType.bytes,
    validateStatus: (status) => status == 200 || status == 401,
    headers: headers,
  );

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

  /// GET returning the decrypted JSON payload.
  Future<Res<dynamic>> get(
    String path, {
    Map<String, String>? header,
    bool isRetry = false,
  }) async {
    final time = _clock();
    try {
      final response = await dio.get<List<int>>(
        '$baseUrl$path',
        options: _options(
          JmHeaderBuilder.build(
            time: time,
            baseUrl: baseUrl,
            device: _device,
            headers: header,
            cookie: cookieHeader,
          ),
        ),
      );
      _captureCookies(response);
      final body = utf8.decode(response.data ?? const <int>[]);
      if (response.statusCode == 401) {
        final message = _errorMessageOf(body);
        if (message == '請先登入會員' && !isRetry) {
          final ok = await _reLogin?.call() ?? false;
          if (ok) {
            return await get(path, header: header, isRetry: true);
          }
        }
        return Res.error(message);
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      final data = json['data'];
      if (data is List) {
        return Res.error(data.isEmpty ? 'Empty data' : 'Data parsing error');
      }
      return Res(jsonDecode(convertData('$data', time)));
    } on DioException catch (e) {
      return Res.error(describeDioError(e));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// POST returning the decrypted JSON payload.
  Future<Res<dynamic>> post(String path, String data) async {
    final time = _clock();
    try {
      final response = await dio.post<List<int>>(
        '$baseUrl$path',
        data: data,
        options: _options(
          JmHeaderBuilder.build(
            time: time,
            baseUrl: baseUrl,
            device: _device,
            cookie: cookieHeader,
            post: true,
          ),
        ),
      );
      _captureCookies(response);
      final body = utf8.decode(response.data ?? const <int>[]);
      if (response.statusCode == 401) {
        return Res.error(_errorMessageOf(body));
      }
      final outer = jsonDecode(body) as Map<String, dynamic>;
      return Res(jsonDecode(convertData('${outer['data']}', time)));
    } on DioException catch (e) {
      return Res.error(describeDioError(e));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  static String _errorMessageOf(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map && json['errorMsg'] != null) {
        return '${json['errorMsg']}';
      }
    } catch (_) {
      // fall through to the generic message
    }
    return 'Unknown Error';
  }

  JmComicBrief _brief(dynamic comic) {
    final map = comic as Map<String, dynamic>;
    final categories = <ComicCategoryInfo>[];
    final category = map['category'];
    if (category is Map && category['id'] != null && category['title'] != null) {
      categories.add(ComicCategoryInfo('${category['id']}', '${category['title']}'));
    }
    final sub = map['category_sub'];
    if (sub is Map && sub['id'] != null && sub['title'] != null) {
      categories.add(ComicCategoryInfo('${sub['id']}', '${sub['title']}'));
    }
    return JmComicBrief(
      '${map['id']}',
      '${map['author'] ?? ''}',
      '${map['name'] ?? ''}',
      '${map['description'] ?? ''}',
      categories,
    );
  }

  List<JmComicBrief> _briefs(dynamic list) {
    final comics = <JmComicBrief>[];
    if (list is! List) return comics;
    for (final comic in list) {
      try {
        comics.add(_brief(comic));
      } catch (_) {
        continue;
      }
    }
    return comics;
  }

  static int _pageCount(dynamic total, int current) {
    if (current == 0) return 0;
    final parsed = total is int ? total : int.tryParse('$total') ?? 0;
    return (parsed / current).ceil();
  }

  /// 主页: `/promote?&page=0`.
  Future<Res<HomePageData>> getHomePage() async {
    final res = await get('/promote?&page=0');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final items = <HomePageItem>[];
      for (final item in res.data as List) {
        final map = item as Map<String, dynamic>;
        final comics = <JmComicBrief>[];
        for (final comic in (map['content'] as List? ?? const [])) {
          try {
            comics.add(_brief(comic));
          } catch (_) {
            continue;
          }
        }
        final type = '${map['type']}';
        var id = '${map['id']}';
        if (type == 'category_id') {
          id = '${map['slug']}';
        }
        items.add(
          HomePageItem('${map['title']}', id, comics, type != 'promote'),
        );
      }
      return Res(HomePageData(items));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/promote_list?&id=<id>&page=0`.
  Future<Res<PromoteList>> getPromoteList(String id) async {
    final res = await get('/promote_list?&id=$id&page=0');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final list = PromoteList(id, []);
      list.total = int.parse('${data['total']}');
      for (final comic in (data['list'] as List)) {
        try {
          list.comics.add(_brief(comic));
        } catch (_) {
          // ignored, like the original
        }
        list.loaded++;
      }
      list.page++;
      return Res(list);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  Future<void> loadMorePromoteListComics(PromoteList list) async {
    if (list.loaded >= list.total) return;
    final res = await get('/promote_list?&id=${list.id}&page=${list.page}');
    if (res.error) return;
    try {
      final data = res.data as Map<String, dynamic>;
      for (final comic in (data['list'] as List)) {
        try {
          list.comics.add(_brief(comic));
        } catch (_) {
          // ignored
        }
        list.loaded++;
      }
      list.page++;
    } catch (_) {
      return;
    }
  }

  /// `/latest?&page=<page>`; `subData` is the original's sentinel `99999`.
  Future<Res<List<JmComicBrief>>> getLatest(int page) async {
    final res = await get('/latest?&page=$page');
    if (res.error) return Res.fromErrorRes(res);
    try {
      return Res(_briefs(res.data), subData: 99999);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/hot_tags?&`
  Future<Res<bool>> getHotTags() async {
    final res = await get('/hot_tags?&');
    if (res.error) return Res.fromErrorRes(res);
    hotTags
      ..clear()
      ..addAll((res.data as List).map((e) => '$e'));
    return const Res(true);
  }

  /// `/search?&search_query=<kw>&o=<order>[&page=<page>]`
  ///
  /// Keyword is percent-encoded and then spaces become `+`; page 1 omits `page`.
  Future<Res<List<JmComicBrief>>> search(
    String keyword,
    int page,
    JmComicsOrder order,
  ) async {
    keyword = keyword.trim().replaceAll('  ', ' ');
    keyword = Uri.encodeComponent(keyword).replaceAll('%20', '+');
    final path = page != 1
        ? '/search?&search_query=$keyword&o=$order&page=$page'
        : '/search?&search_query=$keyword&o=$order';
    final res = await get(path);
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final comics = _briefs(data['content']);
      return Res(
        comics,
        subData: comics.isEmpty
            ? 0
            : _pageCount(data['total'], (data['content'] as List).length),
      );
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/categories?&`
  Future<Res<List<JmCategory>>> getCategories() async {
    final res = await get('/categories?&');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final categories = <JmCategory>[];
      for (final c in (data['categories'] as List)) {
        final map = c as Map<String, dynamic>;
        final subs = <JmSubCategory>[];
        for (final sc in (map['sub_categories'] as List? ?? const [])) {
          subs.add(
            JmSubCategory('${sc['CID']}', '${sc['name']}', '${sc['slug']}'),
          );
        }
        categories.add(JmCategory('${map['name']}', '${map['slug']}', subs));
      }
      return Res(categories);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/categories/filter?&o=<order>&c=<category>&page=<page>`
  Future<Res<List<JmComicBrief>>> getCategoryComics(
    String category,
    JmComicsOrder order,
    int page,
  ) async {
    final res = await get(
      '/categories/filter?&o=$order&c=${Uri.encodeComponent(category)}&page=$page',
    );
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final comics = _briefs(data['content']);
      return Res(comics, subData: _pageCount(data['total'], comics.length));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/album?comicName=&id=<id>`
  Future<Res<JmComicInfo>> getComicInfo(String id) async {
    final res = await get('/album?comicName=&id=$id');
    if (res.error) {
      if (res.errorMessageWithoutNull.contains('Empty data')) {
        throw Exception('漫畫不存在: id = $id');
      }
      return Res.fromErrorRes(res);
    }
    try {
      final data = res.data as Map<String, dynamic>;
      final author = <String>[];
      for (final s in (data['author'] as List? ?? const ['未知'])) {
        author.add('$s');
      }
      final series = <int, String>{};
      final epNames = <String>[];
      var sort = 1;
      for (final s in (data['series'] as List? ?? const [])) {
        series[sort] = '${s['id']}';
        sort++;
        var name = '${s['name']}';
        if (name.isEmpty) {
          name = '第${s['sort']}話';
        }
        epNames.add(name);
      }
      final tags = <String>[];
      for (final s in (data['tags'] as List? ?? const [])) {
        tags.add('$s');
      }
      final related = <JmComicBrief>[];
      for (final c in (data['related_list'] as List? ?? const [])) {
        related.add(
          JmComicBrief(
            '${c['id']}',
            '${c['author'] ?? 'Unknown'}',
            '${c['name'] ?? 'Unknown'}',
            '${c['description'] ?? 'None'}',
            const [],
          ),
        );
      }
      return Res(
        JmComicInfo(
          '${data['name'] ?? '未知'}',
          id,
          author,
          '${data['description'] ?? '无'}',
          int.tryParse('${data['likes'] ?? '0'}') ?? 0,
          int.tryParse('${data['total_views'] ?? '0'}') ?? 0,
          series,
          tags,
          related,
          data['liked'] == true,
          data['is_favorite'] == true,
          int.tryParse('${data['comment_total'] ?? '0'}') ?? 0,
          epNames,
        ),
      );
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `POST /login` with `username` / `password` form fields.
  Future<Res<bool>> login(String account, String pwd) async {
    final res = await post(
      '/login',
      'username=${Uri.encodeComponent(account)}'
      '&password=${Uri.encodeComponent(pwd)}',
    );
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  Future<Res<bool>> loginFromAppdata() async {
    final ok = await _reLogin?.call() ?? false;
    return ok ? const Res(true) : Res.error('error');
  }

  Future<void> logout() async {
    _cookies.clear();
  }

  Future<void> likeComic(String id) async {
    await post('/like', 'id=$id&');
  }

  /// `POST /favorite_folder type=add`
  Future<Res<bool>> createFolder(String name) async {
    final res = await post('/favorite_folder', 'type=add&folder_name=$name&');
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  /// `/favorite?&page=<page>&folder_id=<id>&o=<order>`
  Future<Res<List<JmComicBrief>>> getFolderComicsPage(
    String id,
    int page, {
    JmComicsOrder order = JmComicsOrder.latest,
  }) async {
    final res = await get('/favorite?&page=$page&folder_id=$id&o=$order');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final comics = _briefs(data['list']);
      return Res(comics, subData: _pageCount(data['total'], comics.length));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/favorite?&` -> `folder_list[].FID` / `.name`.
  Future<Res<Map<String, String>>> getFolders() async {
    final res = await get('/favorite?&');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final folders = <String, String>{};
      for (final folder in (data['folder_list'] as List)) {
        folders['${folder['FID']}'] = '${folder['name']}';
      }
      return Res(folders);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `POST /favorite_folder type=move`
  Future<Res<bool>> moveToFolder(String comicId, String folderId) async {
    final res = await post(
      '/favorite_folder',
      'type=move&folder_id=$folderId&aid=$comicId&',
    );
    if (res.error) return Res.fromErrorRes(res);
    return const Res(true);
  }

  /// `POST /favorite aid=<id>`; a `null` [folder] removes the favourite.
  Future<Res<bool>> favorite(String id, String? folder) async {
    try {
      if (folder != null) {
        var res = await post('/favorite', 'aid=$id&');
        if (res.dataOrNull is Map && res.data['type'] != 'add') {
          res = await post('/favorite', 'aid=$id&');
        }
        var res2 = const Res(true);
        if (folder != '0') {
          res2 = await moveToFolder(id, folder);
        }
        if (res.error || res2.error) {
          return Res.error(res.errorMessageWithoutNull);
        }
        return const Res(true);
      }
      var res = await post('/favorite', 'aid=$id&');
      if (res.dataOrNull is Map && res.data['type'] == 'add') {
        res = await post('/favorite', 'aid=$id&');
      }
      return const Res(false);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/chapter?&id=<id>` -> full image URLs.
  Future<Res<List<String>>> getChapter(String id) async {
    final res = await get('/chapter?&id=$id');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final images = <String>[];
      for (final s in (data['images'] as List)) {
        images.add(JmImageUrls.photo('$s', id));
      }
      return Res(images);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/forum?mode=<mode>&aid=<id>&page=<page>`; comment bodies are HTML.
  Future<Res<List<JmComment>>> getComment(
    String id,
    int page, [
    String mode = 'manhua',
  ]) async {
    final res = await get('/forum?mode=$mode&aid=$id&page=$page');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final comments = <JmComment>[];
      for (final c in (data['list'] as List)) {
        final replies = <JmComment>[];
        for (final r in (c['replys'] as List? ?? const [])) {
          replies.add(_comment(r));
        }
        comments.add(_comment(c, replies));
      }
      return Res(
        comments,
        subData: data['total'] is int
            ? data['total']
            : int.tryParse('${data['total']}') ?? 1,
      );
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  JmComment _comment(dynamic raw, [List<JmComment> replies = const []]) {
    final map = raw as Map<String, dynamic>;
    return JmComment(
      '${map['CID']}',
      JmImageUrls.avatar('${map['photo']}'),
      '${map['username']}',
      '${map['addtime']}',
      _parseCommentContent('${map['content']}'),
      replies,
    );
  }

  static String _parseCommentContent(String input) {
    try {
      return parseFragment(input).querySelector('div')?.text ?? '';
    } catch (_) {
      return '';
    }
  }

  /// `POST /favorite_folder type=del`
  Future<Res<bool>> deleteFolder(String id) async {
    final res = await post('/favorite_folder', 'type=del&folder_id=$id&');
    if (res.error) return Res.fromErrorRes(res);
    if (res.dataOrNull is Map && res.data['code'] == 400) {
      return Res.error('${res.data['msg']}');
    }
    return const Res(true);
  }

  /// `/week?&` -> category id -> time label.
  Future<Res<Map<String, String>>> getWeekRecommendation() async {
    final res = await get('/week?&');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      final categories = <String, String>{};
      for (final c in (data['categories'] as List)) {
        categories['${c['id']}'] = '${c['time']}';
      }
      return Res(categories);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `/week/filter?&id=<id>&page=0<type>`
  Future<Res<List<JmComicBrief>>> getWeekRecommendationComics(
    String id,
    JmWeekRecommendationType type,
  ) async {
    final res = await get('/week/filter?&id=$id&page=0$type');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final data = res.data as Map<String, dynamic>;
      return Res(_briefs(data['list']));
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// `POST /comment`
  Future<Res<String>> comment(String aid, String content) async {
    final res = await post(
      '/comment',
      'comment=${Uri.encodeComponent(content)}&status=undefined&aid=$aid&',
    );
    if (res.error) return Res.fromErrorRes(res);
    return Res('${res.data['msg']}');
  }
}

/// A 禁漫天堂 comment (with nested replies).
class JmComment {
  const JmComment(
    this.id,
    this.avatar,
    this.name,
    this.time,
    this.content,
    this.reply,
  );

  final String id;
  final String avatar;
  final String name;
  final String time;
  final String content;
  final List<JmComment> reply;
}
