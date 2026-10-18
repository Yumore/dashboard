import 'package:dashboard/features/anime/animetrace/animetrace_ping_status.dart';

/// A scraper site offered on the source list page (the source app's
/// `ClimbWebsite`).
///
/// [climbId] selects the parser: `age`, `yhdm`, `omofun` or `bangumi`.
/// [enable] and the ping state are user state, persisted through
/// shared_preferences using [spkey].
class AnimeTraceSource {
  const AnimeTraceSource({
    required this.name,
    required this.climbId,
    required this.regexp,
    required this.spkey,
    this.iconUrl = '',
    this.enable = false,
    this.keyword = '',
    this.pingStatus = AnimeTracePingStatus.unknown,
    this.comment = '',
    this.desc = '',
    this.baseUrl = '',
    this.discard = false,
    this.supportImport = true,
    this.supportPlayVideo = false,
  });

  final String name;
  final String climbId;

  /// Regular expression matched against a scraped anime URL to decide which
  /// source produced it (the source app's `regexp` field).
  final String regexp;

  /// shared_preferences key holding the enabled flag.
  final String spkey;

  final String iconUrl;
  final bool enable;
  final String keyword;
  final AnimeTracePingStatus pingStatus;
  final String comment;
  final String desc;

  /// Base URL actually used by the scraper: the user's custom URL when set,
  /// otherwise the scraper's default. Empty means "use the default".
  final String baseUrl;

  /// Sources that no longer work: shown as "无法使用" with no toggle.
  final bool discard;

  /// Whether the source can be imported into the local collection.
  final bool supportImport;

  /// Whether the source exposes a playable stream.
  final bool supportPlayVideo;

  bool matchesUrl(String animeUrl) {
    final pattern = RegExp(regexp);
    return pattern.hasMatch(animeUrl);
  }

  AnimeTraceSource copyWith({
    String? name,
    String? climbId,
    String? regexp,
    String? spkey,
    String? iconUrl,
    bool? enable,
    String? keyword,
    AnimeTracePingStatus? pingStatus,
    String? comment,
    String? desc,
    String? baseUrl,
    bool? discard,
    bool? supportImport,
    bool? supportPlayVideo,
  }) {
    return AnimeTraceSource(
      name: name ?? this.name,
      climbId: climbId ?? this.climbId,
      regexp: regexp ?? this.regexp,
      spkey: spkey ?? this.spkey,
      iconUrl: iconUrl ?? this.iconUrl,
      enable: enable ?? this.enable,
      keyword: keyword ?? this.keyword,
      pingStatus: pingStatus ?? this.pingStatus,
      comment: comment ?? this.comment,
      desc: desc ?? this.desc,
      baseUrl: baseUrl ?? this.baseUrl,
      discard: discard ?? this.discard,
      supportImport: supportImport ?? this.supportImport,
      supportPlayVideo: supportPlayVideo ?? this.supportPlayVideo,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'name': name,
    'climbId': climbId,
    'regexp': regexp,
    'spkey': spkey,
    'iconUrl': iconUrl,
    'enable': enable,
    'keyword': keyword,
    'comment': comment,
    'desc': desc,
    'baseUrl': baseUrl,
    'discard': discard,
    'supportImport': supportImport,
    'supportPlayVideo': supportPlayVideo,
  };

  factory AnimeTraceSource.fromMap(
    Map<String, Object?> map, {
    bool fallbackEnable = false,
  }) {
    String stringOf(String key, [String fallback = '']) {
      final value = map[key];
      return value is String ? value : fallback;
    }

    bool boolOf(String key, bool fallback) {
      final value = map[key];
      return value is bool ? value : fallback;
    }

    return AnimeTraceSource(
      name: stringOf('name'),
      climbId: stringOf('climbId'),
      regexp: stringOf('regexp'),
      spkey: stringOf('spkey'),
      iconUrl: stringOf('iconUrl'),
      enable: boolOf('enable', fallbackEnable),
      keyword: stringOf('keyword'),
      comment: stringOf('comment'),
      desc: stringOf('desc'),
      baseUrl: stringOf('baseUrl'),
      discard: boolOf('discard', false),
      supportImport: boolOf('supportImport', true),
      supportPlayVideo: boolOf('supportPlayVideo', false),
    );
  }

  @override
  String toString() => 'AnimeTraceSource($name, enable=$enable)';
}
