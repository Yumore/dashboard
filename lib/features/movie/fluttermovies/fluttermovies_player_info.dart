import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';

/// `player_info`：线路的展示名与解析配置。
class FlutterMoviesPlayerInfo {
  const FlutterMoviesPlayerInfo({
    this.status = '',
    this.copyrightUrl = '',
    this.from = '',
    this.show = '',
    this.des = '',
    this.target = '',
    this.ps = '',
    this.parse = '',
    this.sort = '',
    this.tip = '',
    this.id = '',
  });

  factory FlutterMoviesPlayerInfo.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesPlayerInfo(
        status: FlutterMoviesJson.asString(json['status']),
        copyrightUrl: FlutterMoviesJson.asString(json['copyright_url']),
        from: FlutterMoviesJson.asString(json['from']),
        show: FlutterMoviesJson.asString(json['show']),
        des: FlutterMoviesJson.asString(json['des']),
        target: FlutterMoviesJson.asString(json['target']),
        ps: FlutterMoviesJson.asString(json['ps']),
        parse: FlutterMoviesJson.asString(json['parse']),
        sort: FlutterMoviesJson.asString(json['sort']),
        tip: FlutterMoviesJson.asString(json['tip']),
        id: FlutterMoviesJson.asString(json['id']),
      );

  static const FlutterMoviesPlayerInfo empty = FlutterMoviesPlayerInfo();

  final String status;
  final String copyrightUrl;
  final String from;
  final String show;
  final String des;
  final String target;
  final String ps;
  final String parse;
  final String sort;
  final String tip;
  final String id;
}
