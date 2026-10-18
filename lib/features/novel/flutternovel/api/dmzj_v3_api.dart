import 'dart:convert';

import 'package:dashboard/features/novel/flutternovel/models/dmzj_recommend_section.dart';
import 'package:http/http.dart' as http;

/// The dmzj v3 client.
///
/// The source declared the endpoint but never implemented it: its
/// `lib/app/api/constance/const_request_url.dart` carries
/// `RequestApi.DMZJ_REFERER_URL = "http://images.dmzj.com/"`,
/// `RequestApi.BASE_URL = "https://v3api.dmzj.com/novel/"` and
/// `RequestApi.HOME_RECOMMEND = BASE_URL + "recommend.json"`, and
/// `lib/app/api/api_home.dart` is a 0-line file. The port implements exactly
/// that declared endpoint — same host, path and `Referer` — and maps the feed
/// onto [DmzjRecommendSection] / DmzjNovelBrief using the dmzj v3 novel keys the
/// host's own dmzj module already consumes.
class DmzjV3Api {
  DmzjV3Api({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? requestTimeout;

  final http.Client _client;
  final Duration _timeout;

  static const String refererUrl = 'http://images.dmzj.com/';
  static const String baseUrl = 'https://v3api.dmzj.com/novel/';
  static const String recommendPath = 'recommend.json';

  static const Duration requestTimeout = Duration(seconds: 20);

  static Uri recommendUri() => Uri.parse(baseUrl + recommendPath);

  /// Accepts the feed's normal top-level JSON array of
  /// `{title, data: [...]}` sections; a bare `{data: [...]}` object is also
  /// accepted, as is a single section object.
  static List<DmzjRecommendSection> parseRecommend(String body) {
    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (element) =>
                DmzjRecommendSection.fromJson(element.cast<String, dynamic>()),
          )
          .toList();
    }

    if (decoded is Map) {
      final map = decoded.cast<String, dynamic>();

      /// A section object carries its own `title` (and/or a `books` list); only
      /// a title-less `{data: [...]}` is a wrapper around a list of sections.
      if (map.containsKey('title') || map.containsKey('books')) {
        return <DmzjRecommendSection>[DmzjRecommendSection.fromJson(map)];
      }

      final data = map['data'];
      if (data is List) {
        return data
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (element) =>
                  DmzjRecommendSection.fromJson(element.cast<String, dynamic>()),
            )
            .toList();
      }
      return <DmzjRecommendSection>[DmzjRecommendSection.fromJson(map)];
    }

    return const <DmzjRecommendSection>[];
  }

  Future<List<DmzjRecommendSection>> fetchRecommend() async {
    try {
      final response = await _client
          .get(
            recommendUri(),
            headers: const <String, String>{
              'Referer': refererUrl,
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        return const <DmzjRecommendSection>[];
      }
      return parseRecommend(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    } catch (_) {
      return const <DmzjRecommendSection>[];
    }
  }

  void close() => _client.close();
}
