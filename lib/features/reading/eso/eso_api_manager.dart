import 'package:dashboard/features/reading/eso/eso_api_from_rule.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_discover_pair.dart';
import 'package:dashboard/features/reading/eso/eso_http_client.dart';
import 'package:dashboard/features/reading/eso/eso_rule_provider.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';

/// 源分发（移植 eso `lib/api/api_manager.dart` 的 `APIManager`）。
///
/// 源实现用全局 `ruleDao` 取源，这里把 [EsoRuleProvider] 注入进来；
/// UI 侧用 [EsoApiManager.configure] 配置单例。
class EsoApiManager {
  EsoApiManager(this.rules, {this.client});

  final EsoRuleProvider rules;

  /// 可注入的 HTTP 客户端（测试用假 client）。
  final EsoHttpClient? client;

  static EsoApiManager? _instance;

  static EsoApiManager get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('EsoApiManager 未配置，请先调用 EsoApiManager.configure()');
    }
    return instance;
  }

  static void configure(EsoRuleProvider rules, {EsoHttpClient? client}) =>
      _instance = EsoApiManager(rules, client: client);

  static void reset() => _instance = null;

  Future<EsoApiFromRule?> chooseApi(String? originTag) async {
    if (originTag == null) return null;
    final rule = await rules.findRuleById(originTag);
    if (rule == null) return null;
    return EsoApiFromRule(rule, client: client);
  }

  Future<List<EsoSearchItem>> discover(
    String? originTag,
    Map<String, EsoDiscoverPair> params, [
    int page = 1,
    int pageSize = 20,
  ]) async {
    final api = await chooseApi(originTag);
    if (api != null) return api.discover(params, page, pageSize);
    return <EsoSearchItem>[];
  }

  Future<List<EsoSearchItem>> search(
    String? originTag,
    String query, [
    int page = 1,
    int pageSize = 20,
  ]) async {
    final api = await chooseApi(originTag);
    if (api != null) return api.search(query.trim(), page, pageSize);
    return <EsoSearchItem>[];
  }

  Future<List<EsoChapterItem>> getChapter(String? originTag, String? url,
      [int? page]) async {
    final api = await chooseApi(originTag);
    if (api != null) return api.chapter(url ?? '', page);
    return <EsoChapterItem>[];
  }

  Future<List<String>> getContent(String? originTag, String? url) async {
    final api = await chooseApi(originTag);
    if (api != null) return api.content(url ?? '');
    return <String>[];
  }
}
