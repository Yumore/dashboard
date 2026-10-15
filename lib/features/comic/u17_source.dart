import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_comic.dart';
import 'package:dashboard/features/comic/u17_comic_detail.dart';
import 'package:dio/dio.dart';

/// Ports comic_flutter's U17 list/detail/chapter endpoints to the host Dio 5.
class U17Source {
  U17Source({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://app.u17.com/v3/appV3_3/android/phone',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
          );

  final Dio _dio;

  Future<List<U17Comic>> list({int page = 1}) async {
    final response = await _dio.get<dynamic>(
      '/list/conditionScreenlists',
      queryParameters: {'page': page, 'v': '5300100'},
    );
    final payload = _payload(response.data);
    if (payload is! Map || payload['comics'] is! List) {
      throw const FormatException('漫画列表格式错误');
    }
    return (payload['comics'] as List)
        .whereType<Map>()
        .map(
          (item) => U17Comic.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id > 0 && item.name.isNotEmpty)
        .toList();
  }

  Future<List<U17Comic>> search(String keyword) async {
    final response = await _dio.get<dynamic>(
      '/search/relative',
      queryParameters: {'inputText': keyword},
    );
    final payload = _payload(response.data);
    if (payload is! List) throw const FormatException('漫画搜索格式错误');
    return payload
        .whereType<Map>()
        .map(
          (item) => U17Comic.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id > 0 && item.name.isNotEmpty)
        .toList();
  }

  Future<List<U17Chapter>> chapters(int comicId) async {
    return (await details(U17Comic(id: comicId, name: ''))).chapters;
  }

  Future<U17ComicDetail> details(U17Comic comic) async {
    final response = await _dio.get<dynamic>(
      '/comic/detail_static_new',
      queryParameters: {'comicid': comic.id},
    );
    final payload = _payload(response.data);
    if (payload is! Map || payload['chapter_list'] is! List) {
      throw const FormatException('漫画章节格式错误');
    }
    final chapters = (payload['chapter_list'] as List)
        .whereType<Map>()
        .map(
          (item) => U17Chapter.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .where((item) => item.id > 0)
        .toList();
    final rawComic = payload['comic'];
    return U17ComicDetail(
      comic: rawComic is Map
          ? U17Comic.fromJson(
              rawComic.map((key, value) => MapEntry(key.toString(), value)),
            )
          : comic,
      chapters: chapters,
    );
  }

  Future<List<Uri>> images(int chapterId) async {
    final response = await _dio.get<dynamic>(
      '/comic/chapterNew',
      queryParameters: {'chapter_id': chapterId},
    );
    final payload = _payload(response.data);
    if (payload is! Map || payload['image_list'] is! List) {
      throw const FormatException('漫画图片格式错误');
    }
    return (payload['image_list'] as List)
        .whereType<Map>()
        .map((item) {
          final candidates = [item['location'], item['img50'], item['img05']];
          final nested = item['images'];
          if (nested is List) {
            for (final image in nested.whereType<Map>()) {
              candidates.add(image['img50'] ?? image['img05']);
            }
          }
          for (final raw in candidates) {
            final uri = Uri.tryParse('${raw ?? ''}');
            if (uri != null &&
                (uri.scheme == 'http' || uri.scheme == 'https') &&
                uri.host.isNotEmpty) {
              return uri;
            }
          }
          return null;
        })
        .whereType<Uri>()
        .toList();
  }

  Object? _payload(Object? response) {
    if (response is! Map || response['data'] is! Map) {
      throw const FormatException('漫画服务返回格式错误');
    }
    final data = response['data'] as Map;
    final status = int.tryParse('${data['stateCode'] ?? 0}') ?? 0;
    if (status != 1 && status != 0) {
      throw FormatException('漫画服务错误：${data['message'] ?? status}');
    }
    return data['returnData'];
  }

  void dispose() => _dio.close();
}
