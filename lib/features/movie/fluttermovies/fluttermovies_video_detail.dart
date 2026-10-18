import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_list_item.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_play_source.dart';

/// 影片详情：列表行字段 + vod_play_list / vod_down_list。
class FlutterMoviesVideoDetail {
  const FlutterMoviesVideoDetail({
    this.item = const FlutterMoviesListItem(),
    this.vodContent = '',
    this.vodPlayFrom = '',
    this.vodPlayServer = '',
    this.vodPlayNote = '',
    this.vodPlayUrl = '',
    this.vodDownFrom = '',
    this.vodDownServer = '',
    this.vodDownNote = '',
    this.vodDownUrl = '',
    this.playSources = const <FlutterMoviesPlaySource>[],
    this.downSources = const <FlutterMoviesPlaySource>[],
  });

  factory FlutterMoviesVideoDetail.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesVideoDetail(
        item: FlutterMoviesListItem.fromJson(json),
        vodContent: FlutterMoviesJson.asString(json['vod_content']),
        vodPlayFrom: FlutterMoviesJson.asString(json['vod_play_from']),
        vodPlayServer: FlutterMoviesJson.asString(json['vod_play_server']),
        vodPlayNote: FlutterMoviesJson.asString(json['vod_play_note']),
        vodPlayUrl: FlutterMoviesJson.asString(json['vod_play_url']),
        vodDownFrom: FlutterMoviesJson.asString(json['vod_down_from']),
        vodDownServer: FlutterMoviesJson.asString(json['vod_down_server']),
        vodDownNote: FlutterMoviesJson.asString(json['vod_down_note']),
        vodDownUrl: FlutterMoviesJson.asString(json['vod_down_url']),
        playSources: FlutterMoviesJson.asMapList(
          json['vod_play_list'],
        ).map(FlutterMoviesPlaySource.fromJson).toList(growable: false),
        downSources: FlutterMoviesJson.asMapList(
          json['vod_down_list'],
        ).map(FlutterMoviesPlaySource.fromJson).toList(growable: false),
      );

  final FlutterMoviesListItem item;
  final String vodContent;
  final String vodPlayFrom;
  final String vodPlayServer;
  final String vodPlayNote;
  final String vodPlayUrl;
  final String vodDownFrom;
  final String vodDownServer;
  final String vodDownNote;
  final String vodDownUrl;
  final List<FlutterMoviesPlaySource> playSources;
  final List<FlutterMoviesPlaySource> downSources;

  int get id => item.vodId;

  String get title => item.vodName;

  String get introduction {
    final content = vodContent.trim();
    return content.isNotEmpty ? content : item.vodBlurb.trim();
  }

  /// MacCMS 用 `$$$` 分隔线路名（vod_play_from / vod_play_server）。
  List<String> get playFromNames => vodPlayFrom
      .split(r'$$$')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);

  List<String> get playServerNames => vodPlayServer
      .split(r'$$$')
      .map((name) => name.trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);
}
