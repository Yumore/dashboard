import 'dart:convert';
import 'dart:typed_data';

import 'package:dashboard/features/comic/picacomic/core/res.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_gg.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_models.dart';
import 'package:dashboard/features/comic/picacomic/network/hitomi_search.dart';
import 'package:dashboard/features/comic/picacomic/network/parsing_utils.dart';
import 'package:dashboard/features/comic/picacomic/network/source_dio.dart';
import 'package:dashboard/features/comic/picacomic/network/web_user_agent.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;

/// Ports PicaComic lib/network/hitomi_network/hitomi_main_network.dart.
///
/// Deviations: the source routed everything through `CachedNetwork` with a
/// `CacheExpiredTime` (cache_network.dart) and through `getProxy()`
/// (http_client.dart); the host has neither, so requests go straight through
/// [dio]. The `appdata.searchHistory` write in `search()` is also dropped --
/// search history lives in the separate host persistence layer.
class HiNetwork {
  HiNetwork({Dio? dio, HitomiSearch Function(String keyword)? searchFactory})
      : dio = dio ?? createSourceDio(),
        _searchFactory = searchFactory;

  factory HiNetwork.shared() => _cached ??= HiNetwork();
  static HiNetwork? _cached;

  /// Test seam.
  static void resetShared() => _cached = null;

  final Dio dio;
  final HitomiSearch Function(String keyword)? _searchFactory;

  final baseUrl = 'https://hitomi.la';
  final gg = GG();

  Map<String, String> get headers => {
    'User-Agent': webUserAgent,
    'Referer': 'https://hitomi.la/',
  };

  /// hitomi_main_network.dart:25-43.
  Future<Res<String>> get(String url) async {
    try {
      final res = await dio.get<String>(
        url,
        options: Options(headers: headers, responseType: ResponseType.plain),
      );
      return Res('${res.data}');
    } catch (e) {
      final message = e.toString() == 'null' ? '未知错误' : e.toString();
      return Res.error(message);
    }
  }

  Future<Res<ComicList>> getComics(String url) async {
    final comicList = ComicList(url);
    final res = await loadNextPage(comicList);
    if (res.error) {
      return Res.fromErrorRes(res);
    }
    return Res(comicList);
  }

  /// hitomi_main_network.dart:56-66 — the window grows by 100 bytes and
  /// `total` comes back as `subData` from the `Content-Range` header.
  Future<Res<bool>> loadNextPage(ComicList comicList) async {
    if (comicList.toLoad >= comicList.total) return const Res(false);
    final comicIds = await fetchComicData(
      comicList.url,
      comicList.toLoad,
      maxLength: comicList.total,
    );
    if (comicIds.error) return Res.fromErrorRes(comicIds);
    comicList.total = int.parse(comicIds.subData as String);
    comicList.toLoad += 100;
    comicList.comicIds.addAll(comicIds.data);
    return const Res(true);
  }

  /// fetch_data.dart:18-64. `Range: bytes=start-end`, little-endian int32 ids,
  /// and `subData` = the value after the `/` in `Content-Range`.
  Future<Res<List<int>>> fetchComicData(
    String url,
    int start, {
    int? maxLength,
    int? endData,
    String? ref,
  }) async {
    try {
      var end = start + 100 - 1;
      if (endData != null) {
        end = endData;
      }
      if (maxLength != null && maxLength < end) {
        end = maxLength;
      }
      final res = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': webUserAgent,
            'Range': 'bytes=$start-$end',
            'Referer': ?ref,
          },
        ),
      );
      final bytes = Uint8List.fromList(res.data ?? const []);
      final comicIds = HitomiSearch.decodeNozomi(bytes);
      final range =
          (res.headers['content-range'] ?? res.headers['Content-Range'])![0];
      var i = 0;
      for (; i < range.length; i++) {
        if (range[i] == '/') break;
      }
      return Res(comicIds, subData: range.substring(i + 1));
    } catch (e) {
      return Res.error(e.toString() == 'null' ? 'Unknown Error' : e.toString());
    }
  }

  /// hitomi_main_network.dart:69-117 — parses
  /// `https://ltn.hitomi.la/galleryblock/<id>.html`.
  Future<Res<HitomiComicBrief>> getComicInfoBrief(String id) async {
    final res = await get('https://ltn.hitomi.la/galleryblock/$id.html');
    if (res.error) return Res.fromErrorRes(res);
    try {
      final document = parse(res.data);
      final linkNode = document.querySelector('h1.lillie > a')!;
      final name = linkNode.text;
      final link = baseUrl + linkNode.attributes['href']!;
      final artist = document.querySelector('div.artist-list a')?.text ?? 'N/A';
      String cover;
      try {
        final source =
            document.querySelector('div.dj-img1 > picture > source') ??
            document.querySelector('div.cg-img1 > picture > source')!;
        cover = source.attributes['data-srcset']!;
        cover = cover.substring(2);
        cover = 'https://a$cover';
        cover = cover.replaceAll(RegExp(r'2x.*'), '');
        cover = cover.removeAllBlank;
        cover = cover.replaceFirst('avifbigtn', 'webpbigtn');
        cover = cover.replaceFirst('.avif', '.webp');
      } catch (_) {
        cover = '';
      }
      final table = document.querySelectorAll(
        'div.dj-content > table.dj-desc > tbody',
      );
      var type = '';
      var lang = '';
      final tags = <Tag>[];
      for (final tr in table[0].children) {
        if (tr.firstChild!.text == 'Type') {
          type = tr.children[1].text;
        } else if (tr.firstChild!.text == 'Language') {
          lang = tr.children[1].text;
        } else if (tr.firstChild!.text == 'Tags') {
          for (final liA in tr.querySelectorAll('td.relatedtags > ul > li > a')) {
            tags.add(Tag(liA.text, liA.attributes['href']!));
          }
        }
      }
      final time = document.querySelector('div.dj-content > p')!.text;
      return Res(
        HitomiComicBrief(name, type, lang, tags, time, artist, link, cover),
      );
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// hitomi_main_network.dart:120-134 -> [HitomiSearch.search].
  Future<Res<List<int>>> search(String keyword) async {
    try {
      final engine = _searchFactory?.call(keyword) ?? HitomiSearch(keyword, dio: dio);
      return await engine.search();
    } catch (e) {
      return Res.error('$e');
    }
  }

  /// hitomi_main_network.dart:137-181 — gallery block plus the
  /// `galleries/<id>.js` payload (stripped down to its JSON object).
  Future<Res<HitomiComic>> getComicInfo(String target) async {
    String id;
    if (target.isNum) {
      id = target;
    } else {
      id = RegExp(r'\d+(?=\.html)').firstMatch(target)![0]!;
    }
    final brief = await getComicInfoBrief(id);
    if (brief.error) return Res.fromErrorRes(brief);
    final res = await get('https://ltn.hitomi.la/galleries/$id.js');
    if (res.error) return Res.fromErrorRes(res);
    final data = res.data.substring(res.data.indexOf('{'));
    final json = const JsonDecoder().convert(data) as Map<String, dynamic>;
    final tags = <Tag>[];
    final files = <HitomiFile>[];
    for (final tag in (json['tags'] as List? ?? const [])) {
      tags.add(Tag(
        tag['tag'] as String,
        '$baseUrl${tag['url']}',
      ));
    }
    for (final file in (json['files'] as List? ?? const [])) {
      files.add(HitomiFile(
        file['name'] as String,
        file['hash'] as String,
        file['haswebp'] == 1,
        file['hasavif'] == 1,
        file['height'] as int,
        file['width'] as int,
        id,
      ));
    }
    return Res(
      HitomiComic(
        id,
        json['title'] as String,
        List<int>.from(json['related'] as List),
        json['type'] as String,
        List<String>.from(
          (json['artists'] as List? ?? const [])
              .map((e) => e['artist'])
              .toList(),
        ),
        json['language_localname'] as String? ?? '',
        tags,
        json['date'] as String,
        files,
        List<String>.from(
          (json['groups'] as List? ?? const [])
              .map((e) => e['group'])
              .toList(),
        ),
        brief.data.cover,
      ),
    );
  }

  /// Reader pages: image_manager.dart:476-477 /
  /// hitomi_comic_page.dart:131-134 build every page url with
  /// `GG.urlFromUrlFromHash(id, file, 'webp', null)`.
  Future<Res<List<String>>> getImageUrls(HitomiComic comic) async {
    try {
      final images = <String>[];
      for (final file in comic.files) {
        images.add(await gg.urlFromUrlFromHash(comic.id, file, 'webp', null));
      }
      return Res(images);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// hitomi_comic_page.dart:126-140 — small thumbnails use the
  /// `webpsmallsmalltn` directory with the `tn` subdomain base.
  Future<Res<List<String>>> getSmallThumbnails(HitomiComic comic) async {
    try {
      final images = <String>[];
      for (final file in comic.files) {
        images.add(
          await gg.urlFromUrlFromHash(
            comic.id,
            file,
            'webpsmallsmalltn',
            'webp',
            'tn',
          ),
        );
      }
      return Res(images);
    } catch (e) {
      return Res.error(e.toString());
    }
  }

  /// hitomi_home_page.dart:44-67 — resolve nozomi ids in batches of 5.
  Future<Res<List<HitomiComicBrief>>> getComicBriefs(List<int> ids) async {
    final briefs = <HitomiComicBrief>[];
    try {
      var futures = <Future<Res<HitomiComicBrief>>>[];
      Future<void> wait() async {
        final result = await Future.wait(futures);
        futures = [];
        for (final r in result) {
          if (r.error) {
            throw Exception(r.errorMessage);
          }
          briefs.add(r.data);
        }
      }

      for (final id in ids) {
        if (futures.length >= 5) {
          await wait();
        }
        futures.add(getComicInfoBrief(id.toString()));
      }
      await wait();
      return Res(briefs);
    } catch (e) {
      return Res.error(e.toString());
    }
  }
}
