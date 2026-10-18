import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';

/// `type_extend`：分类的可筛维度（源站字段名就是 class/area/lang/...）。
class FlutterMoviesCategoryExtend {
  const FlutterMoviesCategoryExtend({
    this.extendClass = '',
    this.extendArea = '',
    this.extendLang = '',
    this.extendYear = '',
    this.extendStar = '',
    this.extendDirector = '',
    this.extendState = '',
    this.extendVersion = '',
  });

  factory FlutterMoviesCategoryExtend.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesCategoryExtend(
        extendClass: FlutterMoviesJson.asString(json['class']),
        extendArea: FlutterMoviesJson.asString(json['area']),
        extendLang: FlutterMoviesJson.asString(json['lang']),
        extendYear: FlutterMoviesJson.asString(json['year']),
        extendStar: FlutterMoviesJson.asString(json['star']),
        extendDirector: FlutterMoviesJson.asString(json['director']),
        extendState: FlutterMoviesJson.asString(json['state']),
        extendVersion: FlutterMoviesJson.asString(json['version']),
      );

  final String extendClass;
  final String extendArea;
  final String extendLang;
  final String extendYear;
  final String extendStar;
  final String extendDirector;
  final String extendState;
  final String extendVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'class': extendClass,
    'area': extendArea,
    'lang': extendLang,
    'year': extendYear,
    'star': extendStar,
    'director': extendDirector,
    'state': extendState,
    'version': extendVersion,
  };
}
