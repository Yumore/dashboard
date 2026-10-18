import 'package:dashboard/features/movie/fluttermovies/fluttermovies_category_extend.dart';
import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';

/// CMS 分类；`type_pid == 0` 即父类（电影 / 电视剧 / 综艺 / 动漫）。
class FlutterMoviesCategory {
  const FlutterMoviesCategory({
    this.typeId = 0,
    this.typeName = '',
    this.typeEn = '',
    this.typeSort = 0,
    this.typeMid = 0,
    this.typePid = 0,
    this.typeStatus = 0,
    this.typeLogo = '',
    this.typePic = '',
    this.typeKey = '',
    this.typeDes = '',
    this.typeTitle = '',
    this.typeUnion = '',
    this.typeJumpurl = '',
    this.extend = const FlutterMoviesCategoryExtend(),
  });

  factory FlutterMoviesCategory.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesCategory(
        typeId: FlutterMoviesJson.asInt(json['type_id']),
        typeName: FlutterMoviesJson.asString(json['type_name']),
        typeEn: FlutterMoviesJson.asString(json['type_en']),
        typeSort: FlutterMoviesJson.asInt(json['type_sort']),
        typeMid: FlutterMoviesJson.asInt(json['type_mid']),
        typePid: FlutterMoviesJson.asInt(json['type_pid']),
        typeStatus: FlutterMoviesJson.asInt(json['type_status']),
        typeLogo: FlutterMoviesJson.asString(json['type_logo']),
        typePic: FlutterMoviesJson.asString(json['type_pic']),
        typeKey: FlutterMoviesJson.asString(json['type_key']),
        typeDes: FlutterMoviesJson.asString(json['type_des']),
        typeTitle: FlutterMoviesJson.asString(json['type_title']),
        typeUnion: FlutterMoviesJson.asString(json['type_union']),
        typeJumpurl: FlutterMoviesJson.asString(json['type_jumpurl']),
        extend: FlutterMoviesCategoryExtend.fromJson(
          FlutterMoviesJson.asMap(json['type_extend']),
        ),
      );

  final int typeId;
  final String typeName;
  final String typeEn;
  final int typeSort;
  final int typeMid;
  final int typePid;
  final int typeStatus;
  final String typeLogo;
  final String typePic;
  final String typeKey;
  final String typeDes;
  final String typeTitle;
  final String typeUnion;
  final String typeJumpurl;
  final FlutterMoviesCategoryExtend extend;

  bool get isParent => typePid == 0;
}
