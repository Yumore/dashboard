import 'package:dashboard/features/reading/book/model/book_info_rule.dart';
import 'package:dashboard/features/reading/book/model/content_rule.dart';
import 'package:dashboard/features/reading/book/model/search_rule.dart';
import 'package:dashboard/features/reading/book/model/toc_rule.dart';

/// Legado-compatible book source (subset used by M1 engine).
class BookSource {
  String bookSourceUrl;
  String bookSourceName;
  String bookSourceGroup;
  int bookSourceType;
  bool enabled;
  bool enabledExplore;
  String header;
  String searchUrl;
  String exploreUrl;
  /// Shared JS helpers (Legado `jsLib`) injected before rule evaluation.
  String jsLib;
  int customOrder;
  int weight;
  int lastUpdateTime;
  int respondTime;
  SearchRule ruleSearch;
  BookInfoRule ruleBookInfo;
  SearchRule ruleExplore;
  TocRule ruleToc;
  ContentRule ruleContent;
  String rawJson;

  BookSource({
    this.bookSourceUrl = '',
    this.bookSourceName = '',
    this.bookSourceGroup = '',
    this.bookSourceType = 0,
    this.enabled = true,
    this.enabledExplore = false,
    this.header = '',
    this.searchUrl = '',
    this.exploreUrl = '',
    this.jsLib = '',
    this.customOrder = 0,
    this.weight = 0,
    this.lastUpdateTime = 0,
    this.respondTime = 0,
    SearchRule? ruleSearch,
    BookInfoRule? ruleBookInfo,
    SearchRule? ruleExplore,
    TocRule? ruleToc,
    ContentRule? ruleContent,
    this.rawJson = '',
  })  : ruleSearch = ruleSearch ?? SearchRule(),
        ruleBookInfo = ruleBookInfo ?? BookInfoRule(),
        ruleExplore = ruleExplore ?? SearchRule(),
        ruleToc = ruleToc ?? TocRule(),
        ruleContent = ruleContent ?? ContentRule();

  factory BookSource.fromLegadoJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return <String, dynamic>{};
    }

    bool asBool(dynamic v, {bool def = true}) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        if (s == 'true' || s == '1') return true;
        if (s == 'false' || s == '0') return false;
      }
      return def;
    }

    int asInt(dynamic v, {int def = 0}) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? def;
      return def;
    }

    return BookSource(
      bookSourceUrl: (json['bookSourceUrl'] ?? '').toString(),
      bookSourceName: (json['bookSourceName'] ?? '').toString(),
      bookSourceGroup: (json['bookSourceGroup'] ?? '').toString(),
      bookSourceType: asInt(json['bookSourceType']),
      enabled: asBool(json['enabled'], def: true),
      enabledExplore: asBool(json['enabledExplore'], def: false),
      header: (json['header'] ?? '').toString(),
      searchUrl: (json['searchUrl'] ?? '').toString(),
      exploreUrl: (json['exploreUrl'] ?? '').toString(),
      jsLib: (json['jsLib'] ?? '').toString(),
      customOrder: asInt(json['customOrder']),
      weight: asInt(json['weight']),
      lastUpdateTime: asInt(json['lastUpdateTime']),
      respondTime: asInt(json['respondTime']),
      ruleSearch: SearchRule.fromJson(asMap(json['ruleSearch'])),
      ruleBookInfo: BookInfoRule.fromJson(asMap(json['ruleBookInfo'])),
      ruleExplore: SearchRule.fromJson(asMap(json['ruleExplore'])),
      ruleToc: TocRule.fromJson(asMap(json['ruleToc'])),
      ruleContent: ContentRule.fromJson(asMap(json['ruleContent'])),
      rawJson: '',
    );
  }

  Map<String, dynamic> toLegadoJson() {
    return {
      'bookSourceUrl': bookSourceUrl,
      'bookSourceName': bookSourceName,
      'bookSourceGroup': bookSourceGroup,
      'bookSourceType': bookSourceType,
      'enabled': enabled,
      'enabledExplore': enabledExplore,
      'header': header,
      'searchUrl': searchUrl,
      'exploreUrl': exploreUrl,
      'jsLib': jsLib,
      'customOrder': customOrder,
      'weight': weight,
      'lastUpdateTime': lastUpdateTime,
      'respondTime': respondTime,
      'ruleSearch': ruleSearch.toJson(),
      'ruleBookInfo': ruleBookInfo.toJson(),
      'ruleExplore': ruleExplore.toJson(),
      'ruleToc': ruleToc.toJson(),
      'ruleContent': ruleContent.toJson(),
    };
  }

  BookSource copyWith({
    String? bookSourceUrl,
    String? bookSourceName,
    String? bookSourceGroup,
    int? bookSourceType,
    bool? enabled,
    bool? enabledExplore,
    String? header,
    String? searchUrl,
    String? exploreUrl,
    String? jsLib,
    int? customOrder,
    int? weight,
    int? lastUpdateTime,
    int? respondTime,
    SearchRule? ruleSearch,
    BookInfoRule? ruleBookInfo,
    SearchRule? ruleExplore,
    TocRule? ruleToc,
    ContentRule? ruleContent,
    String? rawJson,
  }) {
    return BookSource(
      bookSourceUrl: bookSourceUrl ?? this.bookSourceUrl,
      bookSourceName: bookSourceName ?? this.bookSourceName,
      bookSourceGroup: bookSourceGroup ?? this.bookSourceGroup,
      bookSourceType: bookSourceType ?? this.bookSourceType,
      enabled: enabled ?? this.enabled,
      enabledExplore: enabledExplore ?? this.enabledExplore,
      header: header ?? this.header,
      searchUrl: searchUrl ?? this.searchUrl,
      exploreUrl: exploreUrl ?? this.exploreUrl,
      jsLib: jsLib ?? this.jsLib,
      customOrder: customOrder ?? this.customOrder,
      weight: weight ?? this.weight,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      respondTime: respondTime ?? this.respondTime,
      ruleSearch: ruleSearch ?? this.ruleSearch,
      ruleBookInfo: ruleBookInfo ?? this.ruleBookInfo,
      ruleExplore: ruleExplore ?? this.ruleExplore,
      ruleToc: ruleToc ?? this.ruleToc,
      ruleContent: ruleContent ?? this.ruleContent,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  /// True when this source can be used for discovery.
  bool get canExplore =>
      enabled &&
      exploreUrl.trim().isNotEmpty &&
      (enabledExplore || exploreUrl.trim().isNotEmpty);
}

/// One explore category / kind entry parsed from [BookSource.exploreUrl].
