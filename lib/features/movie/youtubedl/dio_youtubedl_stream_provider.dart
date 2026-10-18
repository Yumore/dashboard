import 'dart:convert';

import 'package:dashboard/features/movie/youtubedl/youtubedl_api_endpoints.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_player_response_parser.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_player_result.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_page.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_search_parser.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_provider.dart';
import 'package:dio/dio.dart';

/// Production [YouTubeStreamProvider] that talks to YouTube via `dio`.
class DioYouTubeStreamProvider implements YouTubeStreamProvider {
  DioYouTubeStreamProvider({
    Dio? dio,
    this.playerParser = const YoutubeDlPlayerResponseParser(),
    this.searchParser = const YoutubeDlSearchParser(),
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 30),
               headers: const <String, String>{'User-Agent': _userAgent},
             ),
           );

  static const String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

  final Dio _dio;
  final YoutubeDlPlayerResponseParser playerParser;
  final YoutubeDlSearchParser searchParser;

  @override
  Future<YoutubeDlPlayerResult> loadPlayer(String videoId) async {
    final body = await _post(
      YoutubeDlApiEndpoints.player(videoId),
      YoutubeDlApiEndpoints.playerBody(videoId),
    );
    return playerParser.parse(body);
  }

  @override
  Future<YoutubeDlSearchPage> searchVideos(
    String query, {
    String? continuation,
  }) async {
    final body = await _post(
      YoutubeDlApiEndpoints.search(),
      YoutubeDlApiEndpoints.searchBody(query, continuation: continuation),
    );
    return searchParser.parse(body);
  }

  @override
  Future<List<String>> suggestions(String query) async {
    try {
      final response = await _dio.get<Object?>(
        YoutubeDlApiEndpoints.suggestions(query).toString(),
        options: Options(responseType: ResponseType.json),
      );
      return _parseSuggestions(response.data);
    } on DioException catch (error) {
      throw YoutubeDlStreamException(
        '获取搜索建议失败：${error.message ?? error.type.name}',
      );
    }
  }

  Future<Map<String, dynamic>> _post(Uri uri, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post<Object?>(
        uri.toString(),
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
      return YoutubeDlJson.asMap(response.data);
    } on DioException catch (error) {
      throw YoutubeDlStreamException(
        '请求 YouTube 失败：${error.message ?? error.type.name}',
      );
    }
  }

  static List<String> _parseSuggestions(Object? data) {
    var payload = data;
    if (payload is String) {
      try {
        payload = jsonDecode(payload);
      } on FormatException {
        return const <String>[];
      }
    }
    if (payload is List && payload.length > 1) {
      return YoutubeDlJson.asStringList(payload[1]);
    }
    return const <String>[];
  }
}
