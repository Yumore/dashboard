import 'package:dashboard/features/movie/yyets/yyets_json.dart';
import 'package:dashboard/features/movie/yyets/yyets_movie.dart';
import 'package:dashboard/features/movie/yyets/yyets_resource_item.dart';
import 'package:dashboard/features/movie/yyets/yyets_season.dart';

/// `resource` 子对象 —— 源工程 `DetailPage` 的 `detail["resource"]`。
///
/// 这个对象里混着两种 `id`：外层片子的 `id` 和资源本身的 `id`。源工程评分时
/// 用的是 `resource["id"]`（`Api.rating(resource["id"], ...)`），所以这里单列。
class YyetsResourceInfo {
  const YyetsResourceInfo({this.raw = const <String, dynamic>{}});

  final Map<String, dynamic> raw;

  /// `Api.rating(resource["id"], ...)` 用的分数对象 id。
  String get id => YyetsJson.asString(raw['id']);

  String get channel => YyetsJson.asString(raw['channel']);
  String get channelCn => YyetsJson.asString(raw['channel_cn']);
  String get content => YyetsJson.asString(raw['content']);
  String get level => YyetsJson.asString(raw['level']);
  String get score => YyetsJson.asString(raw['score']);
  String get playStatus => YyetsJson.asString(raw['play_status']);
  String? get posterBig => YyetsJson.asNullableString(raw['poster_b']);

  /// `zimuzu` —— 字幕组；源工程只在非空时显示。
  String? get zimuzu => YyetsJson.asNullableString(raw['zimuzu']);

  /// `category` —— 源工程是数组，`(resource['category'] ?? []).join('/')`。
  List<String> get category => YyetsJson.asStringList(raw['category']);

  /// 源工程 `tagText((resource['category'] ?? []).join('/'))`。
  String get categoryLabel => category.join('/');

  /// 源工程 `resource['level']?.toUpperCase() ?? ""`。
  String get levelLabel => level.toUpperCase();

  bool get isEmpty => raw.isEmpty;

  factory YyetsResourceInfo.fromJson(Map<String, dynamic> json) =>
      YyetsResourceInfo(raw: json);
}

/// 一条热门评论（`detail["comments_hot"]` 的元素）。
///
/// 源工程 `CommentsPage` 只用 `id` 去重，`CommentsWidget` 展示其它字段。
class YyetsComment {
  const YyetsComment({this.raw = const <String, dynamic>{}});

  final Map<String, dynamic> raw;

  String get id => YyetsJson.asString(raw['id']);
  String get content => YyetsJson.asString(raw['content']);
  String get username => YyetsJson.asString(raw['username']);
  int? get dateline => YyetsJson.asNullableInt(raw['dateline']);
  String? get userPic => YyetsJson.asNullableString(raw['userpic']);

  factory YyetsComment.fromJson(Map<String, dynamic> json) =>
      YyetsComment(raw: json);
}

/// `Api.getDetail(id)` 的响应体（`res.data['data']`）。
///
/// 源工程 `DetailPage` 从这里取：`resource`、`movie_items`、`season_list`、
/// `similar`、`comments_hot`、`comments_count`、`share_url`。
class YyetsDetail {
  const YyetsDetail({
    this.resource = const YyetsResourceInfo(),
    this.movieItems = const <YyetsResourceItem>[],
    this.seasons = const <YyetsSeason>[],
    this.similar = const <YyetsMovie>[],
    this.hotComments = const <YyetsComment>[],
    this.commentsCount = 0,
    this.shareUrl = '',
  });

  final YyetsResourceInfo resource;

  /// `movie_items` —— 电影的可播条目（源工程 `MovieResWidget`）。
  final List<YyetsResourceItem> movieItems;

  /// `season_list` —— 剧集的季/集（源工程 `EpisodeWidget`）。
  final List<YyetsSeason> seasons;

  /// `similar` —— 底部推荐（源工程 `MoviesGridWidget`）。
  final List<YyetsMovie> similar;

  /// `comments_hot` —— 热评，源工程直接塞进 `CommentsPage`。
  final List<YyetsComment> hotComments;

  final int commentsCount;
  final String shareUrl;

  /// 源工程 `DetailPage.build` 的分支判断：
  /// `season_list == null || season_list.length == 0` → 电影条目。
  bool get isMovie => seasons.isEmpty;

  /// 源工程 `title`：`cnname(enname)` + `share_url` 分享文案。
  String shareText(YyetsMovie movie) =>
      '${movie.title}\n$shareUrl\n\n来自 人人影视_Flutter';

  factory YyetsDetail.fromJson(Map<String, dynamic> json) => YyetsDetail(
    resource: YyetsResourceInfo.fromJson(YyetsJson.asMap(json['resource'])),
    movieItems: YyetsJson.asMapList(
      json['movie_items'],
    ).map(YyetsResourceItem.fromJson).toList(growable: false),
    seasons: YyetsJson.asMapList(
      json['season_list'],
    ).map(YyetsSeason.fromJson).toList(growable: false),
    similar: YyetsJson.asMapList(
      json['similar'],
    ).map(YyetsMovie.fromJson).toList(growable: false),
    hotComments: YyetsJson.asMapList(
      json['comments_hot'],
    ).map(YyetsComment.fromJson).toList(growable: false),
    commentsCount: YyetsJson.asInt(json['comments_count']),
    shareUrl: YyetsJson.asString(json['share_url']),
  );

  static const YyetsDetail empty = YyetsDetail();
}
