import 'package:dashboard/features/reading/easymygo/entity/source_info.dart';
import 'package:dashboard/features/reading/easymygo/rule/rule_endpoint.dart';

/// A complete declarative source: metadata plus one [RuleEndpoint] per business.
///
/// In EasyMyGo a source was a JS file whose functions were wrapped by
/// `JsMangaHomeComponent` & friends; each wrapper method name mapped 1:1 onto a
/// business below. The port keeps that exact set of businesses.
class RuleSourceDefinition {
  const RuleSourceDefinition({
    required this.info,
    this.baseUrl = '',
    this.homeTab,
    this.secondTab,
    this.homePage,
    this.homeCovers,
    this.search,
    this.detail,
    this.chapters,
    this.read,
    this.volumes,
  });

  static const List<String> businesses = <String>[
    'home_tab',
    'second_tab',
    'home_page',
    'home_covers',
    'search',
    'detail',
    'chapters',
    'read',
    'volumes',
  ];

  final SourceInfo info;
  final String baseUrl;
  final RuleEndpoint? homeTab;
  final RuleEndpoint? secondTab;
  final RuleEndpoint? homePage;
  final RuleEndpoint? homeCovers;
  final RuleEndpoint? search;
  final RuleEndpoint? detail;
  final RuleEndpoint? chapters;
  final RuleEndpoint? read;
  final RuleEndpoint? volumes;

  RuleEndpoint? endpoint(String business) => switch (business) {
    'home_tab' => homeTab,
    'second_tab' => secondTab,
    'home_page' => homePage,
    'home_covers' => homeCovers,
    'search' => search,
    'detail' => detail,
    'chapters' => chapters,
    'read' => read,
    'volumes' => volumes,
    _ => null,
  };

  List<String> get implementedBusinesses =>
      businesses.where((e) => endpoint(e) != null).toList();

  bool has(String business) => endpoint(business) != null;

  /// Returns this definition with a different [info] (the loader stamps the
  /// owning extension package onto it).
  RuleSourceDefinition withInfo(SourceInfo info) => RuleSourceDefinition(
    info: info,
    baseUrl: baseUrl,
    homeTab: homeTab,
    secondTab: secondTab,
    homePage: homePage,
    homeCovers: homeCovers,
    search: search,
    detail: detail,
    chapters: chapters,
    read: read,
    volumes: volumes,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'info': info.toJson(),
    'base_url': baseUrl,
    for (final business in businesses)
      if (endpoint(business) != null) business: endpoint(business)!.toJson(),
  };
}
