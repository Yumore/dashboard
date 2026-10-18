import 'package:dashboard/features/movie/fluttermovies/fluttermovies_json.dart';

/// CMS `list[]` 行（也用于首页幻灯片：leve=9 只是打了推荐位的影片）。
///
/// 字段名与 MacCMS v10 / appapi.php 返回的 `vod_*` 一一对应。
class FlutterMoviesListItem {
  const FlutterMoviesListItem({
    this.vodId = 0,
    this.typeId = 0,
    this.typeId1 = 0,
    this.groupId = 0,
    this.vodName = '',
    this.vodSub = '',
    this.vodEn = '',
    this.vodStatus = 0,
    this.vodLetter = '',
    this.vodColor = '',
    this.vodTag = '',
    this.vodClass = '',
    this.vodPic = '',
    this.vodPicThumb = '',
    this.vodPicSlide = '',
    this.vodActor = '',
    this.vodDirector = '',
    this.vodWriter = '',
    this.vodBlurb = '',
    this.vodRemarks = '',
    this.vodPubdate = '',
    this.vodTotal = 0,
    this.vodSerial = '',
    this.vodArea = '',
    this.vodLang = '',
    this.vodYear = '',
    this.vodVersion = '',
    this.vodState = '',
    this.vodAuthor = '',
    this.vodLevel = 0,
    this.vodHits = 0,
    this.vodHitsDay = 0,
    this.vodHitsWeek = 0,
    this.vodHitsMonth = 0,
    this.vodDuration = '',
    this.vodUp = 0,
    this.vodDown = 0,
    this.vodScore = '',
    this.vodScoreAll = 0,
    this.vodScoreNum = '',
    this.vodDoubanScore = '',
    this.vodTime = 0,
    this.vodContent = '',
  });

  factory FlutterMoviesListItem.fromJson(Map<String, dynamic> json) =>
      FlutterMoviesListItem(
        vodId: FlutterMoviesJson.asInt(json['vod_id']),
        typeId: FlutterMoviesJson.asInt(json['type_id']),
        typeId1: FlutterMoviesJson.asInt(json['type_id_1']),
        groupId: FlutterMoviesJson.asInt(json['group_id']),
        vodName: FlutterMoviesJson.asString(json['vod_name']),
        vodSub: FlutterMoviesJson.asString(json['vod_sub']),
        vodEn: FlutterMoviesJson.asString(json['vod_en']),
        vodStatus: FlutterMoviesJson.asInt(json['vod_status']),
        vodLetter: FlutterMoviesJson.asString(json['vod_letter']),
        vodColor: FlutterMoviesJson.asString(json['vod_color']),
        vodTag: FlutterMoviesJson.asString(json['vod_tag']),
        vodClass: FlutterMoviesJson.asString(json['vod_class']),
        vodPic: FlutterMoviesJson.asString(json['vod_pic']),
        vodPicThumb: FlutterMoviesJson.asString(json['vod_pic_thumb']),
        vodPicSlide: FlutterMoviesJson.asString(json['vod_pic_slide']),
        vodActor: FlutterMoviesJson.asString(json['vod_actor']),
        vodDirector: FlutterMoviesJson.asString(json['vod_director']),
        vodWriter: FlutterMoviesJson.asString(json['vod_writer']),
        vodBlurb: FlutterMoviesJson.asString(json['vod_blurb']),
        vodRemarks: FlutterMoviesJson.asString(json['vod_remarks']),
        vodPubdate: FlutterMoviesJson.asString(json['vod_pubdate']),
        vodTotal: FlutterMoviesJson.asInt(json['vod_total']),
        vodSerial: FlutterMoviesJson.asString(json['vod_serial']),
        vodArea: FlutterMoviesJson.asString(json['vod_area']),
        vodLang: FlutterMoviesJson.asString(json['vod_lang']),
        vodYear: FlutterMoviesJson.asString(json['vod_year']),
        vodVersion: FlutterMoviesJson.asString(json['vod_version']),
        vodState: FlutterMoviesJson.asString(json['vod_state']),
        vodAuthor: FlutterMoviesJson.asString(json['vod_author']),
        vodLevel: FlutterMoviesJson.asInt(json['vod_level']),
        vodHits: FlutterMoviesJson.asInt(json['vod_hits']),
        vodHitsDay: FlutterMoviesJson.asInt(json['vod_hits_day']),
        vodHitsWeek: FlutterMoviesJson.asInt(json['vod_hits_week']),
        vodHitsMonth: FlutterMoviesJson.asInt(json['vod_hits_month']),
        vodDuration: FlutterMoviesJson.asString(json['vod_duration']),
        vodUp: FlutterMoviesJson.asInt(json['vod_up']),
        vodDown: FlutterMoviesJson.asInt(json['vod_down']),
        vodScore: FlutterMoviesJson.asString(json['vod_score']),
        vodScoreAll: FlutterMoviesJson.asInt(json['vod_score_all']),
        vodScoreNum: FlutterMoviesJson.asString(json['vod_score_num']),
        vodDoubanScore: FlutterMoviesJson.asString(json['vod_douban_score']),
        vodTime: FlutterMoviesJson.asInt(json['vod_time']),
        vodContent: FlutterMoviesJson.asString(json['vod_content']),
      );

  final int vodId;
  final int typeId;
  final int typeId1;
  final int groupId;
  final String vodName;
  final String vodSub;
  final String vodEn;
  final int vodStatus;
  final String vodLetter;
  final String vodColor;
  final String vodTag;
  final String vodClass;
  final String vodPic;
  final String vodPicThumb;
  final String vodPicSlide;
  final String vodActor;
  final String vodDirector;
  final String vodWriter;
  final String vodBlurb;
  final String vodRemarks;
  final String vodPubdate;
  final int vodTotal;
  final String vodSerial;
  final String vodArea;
  final String vodLang;
  final String vodYear;
  final String vodVersion;
  final String vodState;
  final String vodAuthor;
  final int vodLevel;
  final int vodHits;
  final int vodHitsDay;
  final int vodHitsWeek;
  final int vodHitsMonth;
  final String vodDuration;
  final int vodUp;
  final int vodDown;

  /// 源站返回字符串（例如 "8.0"），保留原样便于直接展示。
  final String vodScore;
  final int vodScoreAll;
  final String vodScoreNum;
  final String vodDoubanScore;
  final int vodTime;
  final String vodContent;

  String get title => vodName;

  /// 幻灯片优先用横版图（vod_pic_slide），列表用竖版图。
  String get primaryImage => vodPicSlide.isNotEmpty ? vodPicSlide : vodPic;

  String get listImage => vodPic.isNotEmpty ? vodPic : vodPicSlide;

  String get yearLabel => vodYear.isEmpty ? vodRemarks : vodYear;

  String get scoreLabel {
    final value = vodScore.trim();
    if (value.isEmpty || value == '0' || value == '0.0') return '';
    return value;
  }

  DateTime? get updatedAt =>
      vodTime <= 0 ? null : DateTime.fromMillisecondsSinceEpoch(vodTime * 1000);
}
