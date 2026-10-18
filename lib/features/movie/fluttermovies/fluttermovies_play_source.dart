import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_episode.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_player_info.dart';

/// `vod_play_list[]`：一条播放线路（from / url_count / urls）。
class FlutterMoviesPlaySource {
  const FlutterMoviesPlaySource({
    this.sid = 0,
    this.from = '',
    this.server = '',
    this.note = '',
    this.url = '',
    this.urlCount = 0,
    this.player = FlutterMoviesPlayerInfo.empty,
    this.episodes = const <FlutterMoviesPlayEpisode>[],
  });

  factory FlutterMoviesPlaySource.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesPlaySource(
        sid: FlutterMoviesJson.asInt(json['sid']),
        from: FlutterMoviesJson.asString(json['from']),
        server: FlutterMoviesJson.asString(json['server']),
        note: FlutterMoviesJson.asString(json['note']),
        url: FlutterMoviesJson.asString(json['url']),
        urlCount: FlutterMoviesJson.asInt(json['url_count']),
        player: FlutterMoviesPlayerInfo.fromJson(
          FlutterMoviesJson.asMap(json['player_info']),
        ),
        episodes: FlutterMoviesJson.asMapList(
          json['urls'],
        ).map(FlutterMoviesPlayEpisode.fromJson).toList(growable: false),
      );

  /// 源站明确排除的线路。
  static const String excludedFrom = 'ckm3u8';

  final int sid;
  final String from;
  final String server;
  final String note;
  final String url;
  final int urlCount;
  final FlutterMoviesPlayerInfo player;
  final List<FlutterMoviesPlayEpisode> episodes;

  bool get isPlayable => episodes.isNotEmpty;

  /// Tab 文案取 player_info.show（源站如此），缺失时退回 from / server。
  String get label {
    final show = player.show.trim();
    if (show.isNotEmpty) return show;
    if (from.trim().isNotEmpty) return from.trim();
    if (server.trim().isNotEmpty) return server.trim();
    return '线路';
  }

  int get episodeCount => episodes.isNotEmpty ? episodes.length : urlCount;
}
