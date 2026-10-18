import 'package:dashboard/features/movie/yyets/yyets_endpoint.dart';
import 'package:dashboard/features/movie/yyets/yyets_json.dart';

/// 搜索结果 / 榜单 / 相似推荐里的“一部片”。
///
/// 对应源工程 `MovieTile`、`MoviesGridWidget`、`ResultPageState.buildItem`
/// 直接当 Map 用的那个对象。源工程在搜索结果里做了一次字段整理：
///
/// ```dart
/// item.putIfAbsent('id', () => item["itemid"]);
/// item.remove('itemid');
/// ```
///
/// 也就是搜索命中用 `itemid`、其余列表用 `id`。移植版把两种来源都归一到
/// [id]，并原样保留 [itemId] 以便对齐源行为。
class YyetsMovie {
  const YyetsMovie({
    required this.id,
    this.itemId,
    this.cnName = '',
    this.enName = '',
    this.poster,
    this.posterBig,
    this.channel = '',
    this.channelCn = '',
    this.area = '',
    this.category = '',
    this.score = '',
    this.playStatus = '',
    this.typeName = '',
  });

  /// 源 Map 里的 `id`（榜单/详情/相似推荐）。
  final String id;

  /// 源 Map 里的 `itemid`（搜索结果命中）。
  final String? itemId;

  final String cnName;
  final String enName;

  /// `poster` —— 网格与详情头部都优先用它。
  final String? poster;

  /// `poster_b` —— 详情头部的大图。
  final String? posterBig;

  /// `channel` —— `tv` / `movie`，决定资源详情页请求哪组参数。
  final String channel;

  final String channelCn;
  final String area;
  final String category;
  final String score;
  final String playStatus;
  final String typeName;

  /// 源 `DetailPage.title`：`cnname(enname)`。
  String get title {
    final cn = cnName.isEmpty ? '' : cnName;
    if (enName.isEmpty) return cn;
    if (cn.isEmpty) return '($enName)';
    return '$cn($enName)';
  }

  /// 源列表页的兜底显示顺序：`poster ?? poster_b ?? 占位图`。
  String get displayPoster =>
      _nonEmpty(poster) ?? _nonEmpty(posterBig) ?? _placeholderPoster;

  /// 详情头部：`data["poster_b"] ?? resource["poster_b"] ?? data["poster"]`。
  String get displayPosterBig => _nonEmpty(posterBig) ?? displayPoster;

  /// 源工程的 `Image.network` 占位地址（`MoviesGridWidget` 里写死的）。
  static const String _placeholderPoster = 'https://flutter.cn/favicon.ico';

  /// 源 `MoviesGridWidget` 的标题回退链：`cnname ?? enname ?? "$it"`。
  String get gridTitle => _nonEmpty(cnName) ?? _nonEmpty(enName) ?? '(未知影视)';

  static String? _nonEmpty(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  factory YyetsMovie.fromJson(Map<String, dynamic> json) {
    final id = YyetsJson.asString(json['id']);
    final itemId = YyetsJson.asNullableString(json['itemid']);
    return YyetsMovie(
      id: id.isNotEmpty ? id : (itemId ?? ''),
      itemId: itemId,
      cnName: YyetsJson.asString(json['cnname']),
      enName: YyetsJson.asString(json['enname']),
      poster: YyetsJson.asNullableString(json['poster']),
      posterBig: YyetsJson.asNullableString(json['poster_b']),
      channel: YyetsJson.asString(json['channel']),
      channelCn: YyetsJson.asString(json['channel_cn']),
      area: YyetsJson.asString(json['area']),
      category: YyetsJson.asString(json['category']),
      score: YyetsJson.asString(json['score']),
      playStatus: YyetsJson.asString(json['play_status']),
      typeName: YyetsJson.asString(json['type_name']),
    );
  }

  /// 源 `ResultPageState.buildItem` 传进 `MovieTile` 的标签：
  /// `[area, score, play_status, category]`；`FavoritesPage` 换成
  /// `[score, type_name, category, play_status]`。空值在 `tagText` 里被过滤。
  List<String> get searchTags => <String>[
    area,
    score,
    playStatus,
    category,
  ].where((tag) => tag.trim().isNotEmpty).toList(growable: false);

  List<String> get favoriteTags => <String>[
    score,
    typeName,
    category,
    playStatus,
  ].where((tag) => tag.trim().isNotEmpty).toList(growable: false);

  /// 打开资源详情页需要的参数（`ResInfoPage` 读 `id`/`itemid`/`channel`）。
  Map<String, String> get resourceArguments => <String, String>{
    'id': id,
    'itemid': ?itemId,
    'channel': channel,
  };

  /// 源 `Api.detailUrl` 用的 rid。
  String get rid => id;

  /// 便于源工程里 `"$it"` 那种兜底日志。
  @override
  String toString() => title.isEmpty ? '(未知影视)' : title;

  /// 源工程里没有的地方：供页面判断是否能打开详情。
  bool get hasId => id.isNotEmpty;

  /// 源 `DetailPage._buildDetail` 的网络图地址（可能为 null，交由 UI 处理）。
  String? posterForDetail(Map<String, dynamic> resource) =>
      _nonEmpty(posterBig) ??
      YyetsJson.asNullableString(resource['poster_b']) ??
      _nonEmpty(poster);

  /// 源工程资讯列表里的网页地址（仅调试用，保持引用完整）。
  String get sourceArticleUrl => YyetsEndpoint.articleUrl(id);
}
