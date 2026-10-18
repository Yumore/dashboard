import 'dart:convert';

import 'package:dashboard/features/comic/hakacomic/haka_api.dart';

/// Image pointer returned for every thumb / page
/// (`haka_comic/lib/network/models.dart:50-108`).
class HakaImageDetail {
  const HakaImageDetail({
    required this.fileServer,
    required this.path,
    required this.originalName,
  });

  final String fileServer;

  final String path;

  final String originalName;

  factory HakaImageDetail.fromJson(Map<String, dynamic> json) {
    return HakaImageDetail(
      fileServer: json['fileServer'] as String,
      path: json['path'] as String,
      originalName: json['originalName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'fileServer': fileServer,
    'path': path,
    'originalName': originalName,
  };

  /// Lenient parse: accepts null / an instance / a JSON string / any Map.
  ///
  /// Faithful to the source: a malformed JSON *string* propagates the
  /// `FormatException` raised by [jsonDecode] instead of returning null.
  static HakaImageDetail? tryParse(Object? value) {
    if (value == null) return null;
    if (value is HakaImageDetail) return value;

    final decoded = value is String ? jsonDecode(value) : value;
    if (decoded is Map<String, dynamic>) {
      return HakaImageDetail.fromJson(decoded);
    }
    if (decoded is Map) {
      return HakaImageDetail.fromJson(Map<String, dynamic>.from(decoded));
    }
    return null;
  }

  /// Collapses repeated slashes in the URL path.
  static String normalizeUrl(String url) {
    final uri = Uri.parse(url);
    final normalizedPath = uri.path.replaceAll(RegExp(r'/+'), '/');
    return uri.replace(path: normalizedPath).toString();
  }

  /// Public picacomic file server, adding the missing `static/` segment.
  String get directUrl => normalizeUrl(
    fileServer.contains('static')
        ? '$fileServer/$path'
        : '$fileServer/static/$path',
  );

  /// Relay rewrite used by the `go2778` community host.
  String get proxyUrl => directUrl.replaceFirst('picacomic', 'go2778');

  /// Upstream picked between the two from the globally configured host
  /// (`models.dart:101`); here the host is passed in explicitly.
  String urlFor(HakaApi api) {
    return api == HakaApi.picacomic ? directUrl : proxyUrl;
  }

  /// Stable cache identity for `cached_network_image`.
  String get cacheKey => path;
}
