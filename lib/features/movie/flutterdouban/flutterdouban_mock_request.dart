import 'dart:convert';

import 'package:dashboard/features/movie/flutterdouban/flutterdouban_endpoint.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_exception.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_json.dart';
import 'package:flutter/services.dart';

/// Loads a fixture from `assetPath`. Injectable so tests can read the ported
/// files straight off disk without a widget binding.
typedef FlutterDouBanAssetLoader = Future<String> Function(String assetPath);

/// Port of the source's `lib/http/mock_request.dart`.
///
/// The source's `map` (fixture name per `API` constant) is kept verbatim, and
/// `mock2(name)` keeps the raw-name entry point the detail page used
/// (`_mockRequest.mock2("subject_26266893")`,
/// `lib/pages/detail/detail_page.dart:545`).
class FlutterDouBanMockRequest {
  FlutterDouBanMockRequest({FlutterDouBanAssetLoader? loader})
    : _loader = loader ?? _loadFromBundle;

  /// Where the ported fixtures live. `pubspec.yaml` must list this directory
  /// under `flutter: assets:` for the bundled (non-test) mock path to work.
  static const String assetDirectory = 'lib/features/movie/flutterdouban/mock/';

  /// Action → fixture name, ported from `lib/http/mock_request.dart`. The keys
  /// are the source's `API` constants (`API.IN_THEATERS` already embedded
  /// `?apikey=...`, hence the [FlutterDouBanEndpoint.legacyReviews] key).
  static const Map<String, String> map = <String, String>{
    FlutterDouBanEndpoint.inTheaters: 'in_theaters',
    FlutterDouBanEndpoint.comingSoon: 'coming_soon',
    FlutterDouBanEndpoint.top250: 'top250',
    FlutterDouBanEndpoint.weekly: 'weekly',
    FlutterDouBanEndpoint.legacyReviews: 'reviews',
  };

  final FlutterDouBanAssetLoader _loader;

  static Future<String> _loadFromBundle(String assetPath) =>
      rootBundle.loadString(assetPath);

  static String jsonName(String action) => map[action] ?? action;

  static String assetPathFor(String name) => '$assetDirectory$name.json';

  /// Mirrors `MockRequest.get(action)`: the action is an `API` constant.
  Future<Map<String, dynamic>> mock(String action) => _load(jsonName(action));

  /// Mirrors `MockRequest.mock2(name)`: the argument is already a fixture name.
  Future<Map<String, dynamic>> mock2(String name) => _load(name);

  Future<Map<String, dynamic>> _load(String name) async {
    final path = assetPathFor(name);
    final String raw;
    try {
      raw = await _loader(path);
    } catch (_) {
      throw FlutterDouBanException(
        'Mock 数据缺失：$path（需在 pubspec.yaml 的 assets 中登记该目录）',
      );
    }
    try {
      return FlutterDouBanJson.asMap(jsonDecode(raw));
    } on FormatException catch (error) {
      throw FlutterDouBanException('Mock 数据解析失败：$path（${error.message}）');
    }
  }
}
