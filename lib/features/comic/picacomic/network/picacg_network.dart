import 'dart:convert';

import 'package:dashboard/features/comic/picacomic/core/base_comic.dart';
import 'package:dashboard/features/comic/picacomic/core/comment.dart';
import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/json_utils.dart';
import 'package:dashboard/features/comic/picacomic/network/picacg_headers.dart';
import 'package:dashboard/features/comic/picacomic/network/picacg_models.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dio/dio.dart';

/// Raised for a Picacg error envelope (`400` bodies carry `message`).
class PicacgApiException implements Exception {
  const PicacgApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Ports lib/network/picacg_network/methods.dart.
///
/// Every request is signed with [buildPicacgHeaders]; the signature is computed
/// over the relative path *including* its query string, matching PicaComic's
/// `url.replaceAll("$apiUrl/", "")` call.
class PicacgNetwork {
  PicacgNetwork({
    Dio? dio,
    String Function()? tokenProvider,
    Future<bool> Function()? reLogin,
    String Function()? appChannelProvider,
    String Function()? imageQualityProvider,
  })  : dio = dio ?? createSourceDio(baseUrl: picacgApiUrl),
        _tokenProvider = tokenProvider ?? (() => ''),
        _reLogin = reLogin,
        _appChannelProvider = appChannelProvider ?? (() => '3'),
        _imageQualityProvider = imageQualityProvider ?? (() => 'original');

  static const String picacgApiUrl = 'https://picaapi.picacomic.com';

  final Dio dio;
  final String Function() _tokenProvider;
  final Future<bool> Function()? _reLogin;
  final String Function() _appChannelProvider;
  final String Function() _imageQualityProvider;

  String get token => _tokenProvider();

  // ---------------------------------------------------------------- plumbing

  Future<Res<Map<String, dynamic>>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool allowRetry = true,
  }) async {
    final isAuth = path.startsWith('auth/');
    if (!isAuth && token.isEmpty) {
      return const Res.error('未登录');
    }
    try {
      final response = await dio.request<String>(
        '$picacgApiUrl/$path',
        data: body,
        options: Options(
          method: method,
          responseType: ResponseType.plain,
          headers: buildPicacgHeaders(
            method: method,
            token: token,
            url: path,
            appChannel: _appChannelProvider(),
            imageQuality: _imageQualityProvider(),
          ),
          validateStatus: (code) => code == 200 || code == 400 || code == 401,
        ),
      );
      final code = response.statusCode ?? 0;
      final raw = response.data ?? '';
      if (code == 200) {
        return Res(_decode(raw));
      }
      if (code == 400) {
        return Res.error(_decode(raw)['message']?.toString() ?? 'Bad Request');
      }
      if (code == 401) {
        if (allowRetry && _reLogin != null && await _reLogin()) {
          return await _send(method, path, body: body, allowRetry: false);
        }
        return const Res.error('登录失效且重新登录失败');
      }
      return Res.error('Invalid Status Code $code');
    } on DioException catch (error) {
      return Res.error(_dioMessage(error));
    } catch (error) {
      return Res.error(error.toString());
    }
  }

  Future<Res<Map<String, dynamic>>> _get(String path) => _send('get', path);

  Future<Res<Map<String, dynamic>>> _post(
    String path, [
    Map<String, dynamic>? body,
  ]) =>
      _send('post', path, body: body);

  Map<String, dynamic> _decode(String raw) {
    final decoded = jsonDecode(raw);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : const {};
  }

  String _dioMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return '连接超时';
    }
    if (error.type != DioExceptionType.unknown && error.message != null) {
      return error.message!;
    }
    return error.toString().split('\n').first;
  }

  /// Reads `data.comics.docs` + `data.comics.pages` (also used by search).
  Res<List<BaseComic>> _docsToComics(Map<String, dynamic> json, String root) {
    try {
      final comics = <BaseComic>[];
      for (final doc in (jsonAt(json, '$root.docs') as List? ?? const [])) {
        if (doc is Map) {
          comics.add(
            PicacgComicBrief.fromApiJson(Map<String, dynamic>.from(doc)),
          );
        }
      }
      return Res(comics, subData: jsonAt(json, '$root.pages'));
    } catch (error) {
      return Res.error(error.toString());
    }
  }

  // ------------------------------------------------------------------ account

  Future<Res<String>> login(String email, String password) async {
    final response = await _post('auth/sign-in', <String, dynamic>{
      'email': email,
      'password': password,
    });
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final sessionToken = jsonAt(response.data, 'data.token');
    if (sessionToken is! String || sessionToken.isEmpty) {
      return const Res.error('登录失败');
    }
    return Res(sessionToken);
  }

  Future<Res<PicacgProfile>> getProfile() async {
    final response = await _get('users/profile');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    try {
      return Res(
        PicacgProfile.fromApiJson(
          Map<String, dynamic>.from(jsonAt(response.data, 'data.user') as Map),
        ),
      );
    } catch (error) {
      return Res.error(error.toString());
    }
  }

  Future<Res<List<String>>> getKeywords() async {
    final response = await _get('keywords');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return Res(<String>[
      for (final item in (jsonAt(response.data, 'data.keywords') as List? ?? const []))
        item.toString(),
    ]);
  }

  Future<Res<List<PicacgCategoryItem>>> getCategories() async {
    final response = await _get('categories');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final categories = <PicacgCategoryItem>[];
    for (final item in (jsonAt(response.data, 'data.categories') as List? ?? const [])) {
      if (item is! Map) continue;
      if (item['isWeb'] == true) continue;
      final thumb = item['thumb'];
      final thumbMap = thumb is Map ? thumb : const <String, dynamic>{};
      final fileServer = thumbMap['fileServer']?.toString() ?? '';
      final path = thumbMap['path']?.toString() ?? '';
      categories.add(
        PicacgCategoryItem(
          item['title']?.toString() ?? '',
          (fileServer.isEmpty || path.isEmpty)
              ? ''
              : buildPicacgCategoryImageUrl(fileServer, path),
        ),
      );
    }
    return Res(categories);
  }

  // ------------------------------------------------------------------ listings

  Future<Res<List<BaseComic>>> search(
    String keyword,
    String sort,
    int page,
  ) async {
    final response = await _post(
      'comics/advanced-search?page=$page',
      <String, dynamic>{'keyword': keyword, 'sort': sort},
    );
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return _docsToComics(response.data, 'data.comics');
  }

  Future<Res<List<BaseComic>>> getCategoryComics({
    required String category,
    required int page,
    String type = 'c',
    String sort = 'dd',
  }) async {
    final response =
        await _get('comics?page=$page&$type=${Uri.encodeComponent(category)}&s=$sort');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return _docsToComics(response.data, 'data.comics');
  }

  Future<Res<List<BaseComic>>> getLatest(int page) async {
    final response = await _get('comics?page=$page&s=dd');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return _docsToComics(response.data, 'data.comics');
  }

  Future<Res<List<BaseComic>>> getRandomComics() async {
    final response = await _get('comics/random');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final comics = <BaseComic>[];
    for (final item in (jsonAt(response.data, 'data.comics') as List? ?? const [])) {
      if (item is Map) {
        comics.add(PicacgComicBrief.fromApiJson(Map<String, dynamic>.from(item)));
      }
    }
    return Res(comics);
  }

  Future<Res<List<BaseComic>>> getLeaderboard(String time) async {
    final response = await _get('comics/leaderboard?tt=$time&ct=VC');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final comics = <BaseComic>[];
    for (final item in (jsonAt(response.data, 'data.comics') as List? ?? const [])) {
      if (item is Map) {
        comics.add(PicacgComicBrief.fromApiJson(Map<String, dynamic>.from(item)));
      }
    }
    return Res(comics);
  }

  Future<Res<List<BaseComic>>> getFavorites(
    int page, {
    bool newToOld = true,
  }) async {
    final sort = newToOld ? 'dd' : 'da';
    final response = await _get('users/favourite?s=$sort&page=$page');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return _docsToComics(response.data, 'data.comics');
  }

  Future<Res<bool>> favouriteOrUnfavouriteComic(String id) async {
    final response = await _post('comics/$id/favourite', <String, dynamic>{});
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return const Res(true);
  }

  // -------------------------------------------------------------------- detail

  Future<Res<PicacgComicItem>> getComicInfo(String id) async {
    final response = await _get('comics/$id');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final epsResponse = await getEps(id);
    if (epsResponse.error) return Res.error(epsResponse.errorMessageWithoutNull);
    var recommendations = await getRecommendation(id);
    if (recommendations.error) recommendations = const Res(<PicacgComicBrief>[]);
    try {
      final comic =
          Map<String, dynamic>.from(jsonAt(response.data, 'data.comic') as Map);
      final creator =
          Map<String, dynamic>.from(comic['_creator'] as Map? ?? const {});
      final avatar = creator['avatar'];
      final avatarMap = avatar is Map ? avatar : const <String, dynamic>{};
      final avatarFileServer = avatarMap['fileServer']?.toString() ?? '';
      final avatarPath = avatarMap['path']?.toString() ?? '';
      final thumb =
          Map<String, dynamic>.from(comic['thumb'] as Map? ?? const {});
      final thumbFileServer = thumb['fileServer']?.toString() ?? '';
      final thumbPath = thumb['path']?.toString() ?? '';
      return Res(
        PicacgComicItem(
          creator: PicacgProfile(
            id: comic['_id']?.toString() ?? '',
            avatarUrl: (avatarFileServer.isEmpty || avatarPath.isEmpty)
                ? picacgDefaultAvatarUrl
                : buildPicacgImageUrl(avatarFileServer, avatarPath),
            email: '',
            exp: (creator['exp'] as num?)?.toInt() ?? 0,
            level: (creator['level'] as num?)?.toInt() ?? 0,
            name: creator['name']?.toString() ?? '',
            title: creator['title']?.toString() ?? 'Unknown',
            slogan: creator['slogan']?.toString() ?? '无',
          ),
          title: comic['title']?.toString() ?? 'Unknown',
          description: comic['description']?.toString() ?? '无',
          thumbUrl: (thumbFileServer.isEmpty || thumbPath.isEmpty)
              ? ''
              : buildPicacgImageUrl(thumbFileServer, thumbPath),
          author: comic['author']?.toString() ?? 'Unknown',
          chineseTeam: comic['chineseTeam']?.toString() ?? 'Unknown',
          categories: <String>[
            for (final item in (comic['categories'] as List?) ?? const [])
              item.toString(),
          ],
          tags: <String>[
            for (final item in (comic['tags'] as List?) ?? const []) item.toString(),
          ],
          likes: (comic['likesCount'] as num?)?.toInt() ?? 0,
          comments: (comic['commentsCount'] as num?)?.toInt() ?? 0,
          isFavourite: comic['isFavourite'] as bool? ?? false,
          isLiked: comic['isLiked'] as bool? ?? false,
          epsCount: (comic['epsCount'] as num?)?.toInt() ?? 0,
          id: id,
          pagesCount: (comic['pagesCount'] as num?)?.toInt() ?? 0,
          time: comic['updated_at']?.toString() ?? '',
          eps: epsResponse.data,
          recommendation: recommendations.data,
        ),
      );
    } catch (error) {
      return Res.error(error.toString());
    }
  }

  /// Walks `/comics/{id}/eps?page=N` until `data.eps.pages == N`, then reverses
  /// the collected titles exactly like the original.
  Future<Res<List<String>>> getEps(String id) async {
    final eps = <String>[];
    try {
      var page = 1;
      var hasMore = true;
      while (hasMore) {
        final response = await _get('comics/$id/eps?page=$page');
        if (response.error) return Res.error(response.errorMessageWithoutNull);
        if (jsonInt(response.data, 'data.eps.pages') == page) hasMore = false;
        for (final doc in (jsonAt(response.data, 'data.eps.docs') as List? ?? const [])) {
          if (doc is Map) eps.add(doc['title']?.toString() ?? '');
        }
        page++;
      }
    } catch (error) {
      return Res.error(error.toString());
    }
    return Res(eps.reversed.toList());
  }

  /// Walks `/comics/{id}/order/{order}/pages?page=N`.
  Future<Res<List<String>>> getComicContent(String id, int order) async {
    final urls = <String>[];
    var page = 1;
    var hasMore = true;
    while (hasMore) {
      final response = await _get('comics/$id/order/$order/pages?page=$page');
      if (response.error) return Res.error(response.errorMessageWithoutNull);
      if (jsonInt(response.data, 'data.pages.pages') == page) hasMore = false;
      for (final doc in (jsonAt(response.data, 'data.pages.docs') as List? ?? const [])) {
        if (doc is! Map) continue;
        final media = doc['media'];
        final mediaMap = media is Map ? media : const <String, dynamic>{};
        final fileServer = mediaMap['fileServer']?.toString() ?? '';
        final path = mediaMap['path']?.toString() ?? '';
        if (fileServer.isEmpty || path.isEmpty) continue;
        urls.add(buildPicacgImageUrl(fileServer, path));
      }
      page++;
    }
    return Res(urls);
  }

  Future<Res<List<PicacgComicBrief>>> getRecommendation(String id) async {
    final response = await _get('comics/$id/recommendation');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    final comics = <PicacgComicBrief>[];
    for (final item in (jsonAt(response.data, 'data.comics') as List? ?? const [])) {
      if (item is Map) {
        comics.add(PicacgComicBrief.fromApiJson(Map<String, dynamic>.from(item)));
      }
    }
    return Res(comics);
  }

  // ------------------------------------------------------------------ comments

  Future<Res<List<Comment>>> loadComments(
    String id, {
    String type = 'comics',
    int page = 1,
  }) async {
    final response = await _get('$type/$id/comments?page=$page');
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return Res(<Comment>[
      for (final doc in (jsonAt(response.data, 'data.comments.docs') as List? ?? const []))
        if (doc is Map)
          _toComment(PicacgComment.fromApiJson(Map<String, dynamic>.from(doc))),
    ], subData: jsonAt(response.data, 'data.comments.pages'));
  }

  Future<Res<bool>> sendComment(
    String id,
    String content, {
    String? replyTo,
    String type = 'comics',
  }) async {
    final response = replyTo == null
        ? await _post('$type/$id/comments', <String, dynamic>{'content': content})
        : await _post('comments/$replyTo', <String, dynamic>{'content': content});
    if (response.error) return Res.error(response.errorMessageWithoutNull);
    return const Res(true);
  }

  Comment _toComment(PicacgComment comment) => Comment(
        comment.name,
        comment.avatarUrl,
        comment.text,
        comment.time,
        comment.reply,
        comment.id,
      );
}
