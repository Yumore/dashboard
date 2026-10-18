import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_episode.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_ugc_season.dart';

/// The `data` object of `GET /x/web-interface/view`.
///
/// Ports `VideoSecEntity` from the source app's `entities/video_sec_entity.dart`
/// without the JSON-required-null assertions: the source threw when a field was
/// missing, this mapping degrades to zero values instead.
class BiliVideoInfo {
  const BiliVideoInfo({
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.pic,
    required this.title,
    required this.pubdate,
    required this.ctime,
    required this.desc,
    required this.duration,
    required this.dynamicText,
    required this.seasonId,
    this.ugcSeason,
  });

  final String bvid;
  final int aid;

  /// Top-level `cid`, i.e. the first part of the video. The source app sent
  /// exactly this value to `x/player/playurl`.
  final int cid;
  final String pic;
  final String title;
  final int pubdate;
  final int ctime;
  final String desc;

  /// `duration` in **seconds** for the `view` endpoint (the play-url `durl`
  /// length is in **milliseconds**; the two are not interchangeable).
  final int duration;
  final String dynamicText;
  final int seasonId;
  final BiliUgcSeason? ugcSeason;

  /// Episodes of the ugc collection, empty for a plain single-part video.
  List<BiliUgcEpisode> get episodes => ugcSeason?.episodes ?? const [];

  bool get isCollection => episodes.isNotEmpty;

  /// The cid to resolve when no episode was picked explicitly: the source's
  /// top-level `cid`, falling back to the first collection episode.
  int get primaryCid {
    if (cid > 0) return cid;
    final first = episodes.isEmpty ? null : episodes.first;
    return first?.cid ?? 0;
  }

  factory BiliVideoInfo.fromJson(Map<String, dynamic> json) {
    final season = json['ugc_season'];
    return BiliVideoInfo(
      bvid: '${json['bvid'] ?? ''}',
      aid: _asInt(json['aid']),
      cid: _asInt(json['cid']),
      pic: '${json['pic'] ?? ''}',
      title: '${json['title'] ?? ''}',
      pubdate: _asInt(json['pubdate']),
      ctime: _asInt(json['ctime']),
      desc: '${json['desc'] ?? ''}',
      duration: _asInt(json['duration']),
      dynamicText: '${json['dynamic'] ?? ''}',
      seasonId: _asInt(json['season_id']),
      ugcSeason: season is Map
          ? BiliUgcSeason.fromJson(Map<String, dynamic>.from(season))
          : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'bvid': bvid,
    'aid': aid,
    'cid': cid,
    'pic': pic,
    'title': title,
    'pubdate': pubdate,
    'ctime': ctime,
    'desc': desc,
    'duration': duration,
    'dynamic': dynamicText,
    'season_id': seasonId,
    if (ugcSeason != null) 'ugc_season': ugcSeason!.toJson(),
  };
}

int _asInt(Object? value) => value is int ? value : int.tryParse('$value') ?? 0;
