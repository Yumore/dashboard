import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic_type.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Full comic detail payload (`getcomicinfo_body`).
///
/// The source kept ~50 charge/SEO fields; this port keeps the ones the migrated
/// screens actually read plus the charge flags that gate the reader.
///
/// Source: `lib/models/comic_info_body.dart` → `ComicInfoBody`.
class ManhuataiDetail {
  const ManhuataiDetail({
    required this.servicetime,
    required this.comicName,
    required this.comicTypeLegacy,
    required this.comicTypeNew,
    required this.updateStatusStr,
    required this.seoTitle,
    required this.seoKeywords,
    required this.seoDescription,
    required this.comicStatus,
    required this.comicAuthor,
    required this.comicDesc,
    required this.comicNotice,
    required this.comicCopyright,
    required this.lastChapterId,
    required this.lastChapterName,
    required this.copyrightType,
    required this.readtype,
    required this.humanType,
    required this.copyrightTypeCn,
    required this.backgroundColor,
    required this.comicShareUrl,
    required this.updateTime,
    required this.coverChargeStatus,
    required this.comicMedia,
    required this.siteStatus,
    required this.shoucang,
    required this.renqi,
    required this.comicChapter,
    required this.allprice,
    required this.chargeStatus,
    required this.chargePaid,
    required this.coverList,
  });

  final int servicetime;
  final String comicName;

  /// `comic_type` is a small map (rexue/shenmo/jingji/jingpin) whose values are
  /// already display strings.
  final Map<String, String> comicTypeLegacy;
  final List<ManhuataiComicType> comicTypeNew;
  final String updateStatusStr;
  final String seoTitle;
  final String seoKeywords;
  final String seoDescription;
  final int comicStatus;
  final String comicAuthor;
  final String comicDesc;
  final String comicNotice;
  final String comicCopyright;
  final String lastChapterId;
  final String lastChapterName;
  final int copyrightType;
  final int readtype;
  final int humanType;
  final String copyrightTypeCn;
  final String backgroundColor;
  final String comicShareUrl;
  final int updateTime;
  final String coverChargeStatus;
  final String comicMedia;
  final String siteStatus;
  final int shoucang;
  final String renqi;
  final List<ManhuataiChapter> comicChapter;

  /// Whole-comic price in coins.
  final int allprice;
  final String chargeStatus;

  /// `1` means the current user already paid for the locked content.
  final int chargePaid;

  /// CDN paths for the alternate covers shown on the detail header.
  final List<String> coverList;

  static const ManhuataiDetail empty = ManhuataiDetail(
    servicetime: 0,
    comicName: '',
    comicTypeLegacy: <String, String>{},
    comicTypeNew: <ManhuataiComicType>[],
    updateStatusStr: '',
    seoTitle: '',
    seoKeywords: '',
    seoDescription: '',
    comicStatus: 0,
    comicAuthor: '',
    comicDesc: '',
    comicNotice: '',
    comicCopyright: '',
    lastChapterId: '',
    lastChapterName: '',
    copyrightType: 0,
    readtype: 0,
    humanType: 0,
    copyrightTypeCn: '',
    backgroundColor: '',
    comicShareUrl: '',
    updateTime: 0,
    coverChargeStatus: '',
    comicMedia: '',
    siteStatus: '',
    shoucang: 0,
    renqi: '',
    comicChapter: <ManhuataiChapter>[],
    allprice: 0,
    chargeStatus: '',
    chargePaid: 0,
    coverList: <String>[],
  );

  bool get isEmpty => comicName.isEmpty && comicChapter.isEmpty;

  /// Newest-first chapter list, as the detail page builds its default view.
  List<ManhuataiChapter> get chaptersNewestFirst =>
      comicChapter.reversed.toList();

  factory ManhuataiDetail.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiDetail(
      servicetime: ManhuataiJson.asInt(source['servicetime']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      comicTypeLegacy: ManhuataiJson.map(source['comic_type'])
          .map((key, value) => MapEntry(key, ManhuataiJson.asString(value))),
      comicTypeNew: ManhuataiJson.maps(source['comic_type_new'])
          .map(ManhuataiComicType.fromJson)
          .toList(),
      updateStatusStr: ManhuataiJson.asString(source['update_status_str']),
      seoTitle: ManhuataiJson.asString(source['seo_title']),
      seoKeywords: ManhuataiJson.asString(source['seo_keywords']),
      seoDescription: ManhuataiJson.asString(source['seo_description']),
      comicStatus: ManhuataiJson.asInt(source['comic_status']),
      comicAuthor: ManhuataiJson.asString(source['comic_author']),
      comicDesc: ManhuataiJson.asString(source['comic_desc']),
      comicNotice: ManhuataiJson.asString(source['comic_notice']),
      comicCopyright: ManhuataiJson.asString(source['comic_copyright']),
      lastChapterId: ManhuataiJson.asString(source['last_chapter_id']),
      lastChapterName: ManhuataiJson.asString(source['last_chapter_name']),
      copyrightType: ManhuataiJson.asInt(source['copyright_type']),
      readtype: ManhuataiJson.asInt(source['readtype']),
      humanType: ManhuataiJson.asInt(source['human_type']),
      copyrightTypeCn: ManhuataiJson.asString(source['copyright_type_cn']),
      backgroundColor: ManhuataiJson.asString(source['background_color']),
      comicShareUrl: ManhuataiJson.asString(source['comic_share_url']),
      updateTime: ManhuataiJson.asInt(source['update_time']),
      coverChargeStatus: ManhuataiJson.asString(source['cover_charge_status']),
      comicMedia: ManhuataiJson.asString(source['comic_media']),
      siteStatus: ManhuataiJson.asString(source['site_status']),
      shoucang: ManhuataiJson.asInt(source['shoucang']),
      renqi: ManhuataiJson.asDynamicString(source['renqi']),
      comicChapter: ManhuataiJson.maps(source['comic_chapter'])
          .map(ManhuataiChapter.fromJson)
          .toList(),
      allprice: ManhuataiJson.asInt(source['allprice']),
      chargeStatus: ManhuataiJson.asString(source['charge_status']),
      chargePaid: ManhuataiJson.asInt(source['charge_paid']),
      coverList: ManhuataiJson.asStringList(source['cover_list']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'servicetime': servicetime,
        'comic_name': comicName,
        'comic_type': comicTypeLegacy,
        'comic_type_new':
            comicTypeNew.map((type) => type.toJson()).toList(),
        'update_status_str': updateStatusStr,
        'seo_title': seoTitle,
        'seo_keywords': seoKeywords,
        'seo_description': seoDescription,
        'comic_status': comicStatus,
        'comic_author': comicAuthor,
        'comic_desc': comicDesc,
        'comic_notice': comicNotice,
        'comic_copyright': comicCopyright,
        'last_chapter_id': lastChapterId,
        'last_chapter_name': lastChapterName,
        'copyright_type': copyrightType,
        'readtype': readtype,
        'human_type': humanType,
        'copyright_type_cn': copyrightTypeCn,
        'background_color': backgroundColor,
        'comic_share_url': comicShareUrl,
        'update_time': updateTime,
        'cover_charge_status': coverChargeStatus,
        'comic_media': comicMedia,
        'site_status': siteStatus,
        'shoucang': shoucang,
        'renqi': renqi,
        'comic_chapter': comicChapter.map((item) => item.toJson()).toList(),
        'allprice': allprice,
        'charge_status': chargeStatus,
        'charge_paid': chargePaid,
        'cover_list': coverList,
      };
}
