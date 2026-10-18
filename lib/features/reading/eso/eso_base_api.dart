import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_discover_map.dart';
import 'package:dashboard/features/reading/eso/eso_discover_pair.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';

/// 空实现（移植 eso `lib/api/api.dart` 的 `BaseAPI`），未实现的源返回空列表。
class EsoBaseApi implements EsoApi {
  EsoBaseApi({String? origin, String? originTag, int? ruleContentType})
      : _origin = origin,
        _originTag = originTag,
        _ruleContentType = ruleContentType;

  final String? _origin;
  final String? _originTag;
  final int? _ruleContentType;

  @override
  String get origin => _origin ?? '';

  @override
  String get originTag => _originTag ?? '';

  @override
  int get ruleContentType => _ruleContentType ?? EsoApi.manga;

  @override
  Future<List<EsoSearchItem>> discover(
          Map<String, EsoDiscoverPair> params, int page, int pageSize) async =>
      <EsoSearchItem>[];

  @override
  Future<List<EsoSearchItem>> search(String query, int page, int pageSize) async =>
      <EsoSearchItem>[];

  @override
  Future<List<EsoChapterItem>> chapter(String url, [int? page]) async =>
      <EsoChapterItem>[];

  @override
  Future<List<String>> content(String url) async => <String>[];

  @override
  Future<List<EsoDiscoverMap>> discoverMap() async => <EsoDiscoverMap>[];
}
