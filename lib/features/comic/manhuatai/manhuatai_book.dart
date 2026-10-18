import 'package:dashboard/features/comic/manhuatai/manhuatai_book_config.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One titled section of the home page (a "book" in CMS terminology).
///
/// Source: `lib/models/book_list.dart` → `Book`.
class ManhuataiBook {
  const ManhuataiBook({
    required this.bookId,
    required this.siteid,
    required this.modularType,
    required this.unionType,
    required this.unionId,
    required this.istop,
    required this.topNum,
    required this.ordernum,
    required this.versionFilter,
    required this.versionNum,
    required this.title,
    required this.config,
    required this.bookcomicOrder,
    required this.bookcomicImgstyle,
    required this.advertiseLocation,
    required this.advertiseSdktype,
    required this.bookDatasource,
    required this.bookIntellrecommend,
    required this.comicInfo,
  });

  final int bookId;
  final int siteid;
  final int modularType;
  final int unionType;
  final int unionId;
  final int istop;
  final int topNum;
  final int ordernum;
  final int versionFilter;
  final String versionNum;
  final String title;
  final ManhuataiBookConfig config;
  final int bookcomicOrder;
  final int bookcomicImgstyle;
  final String advertiseLocation;
  final int advertiseSdktype;
  final int bookDatasource;
  final int bookIntellrecommend;
  final List<ManhuataiComic> comicInfo;

  /// `isshowmore == 1` renders the "更多" jump into the album page.
  bool get showsMore => config.isShowMore == 1;

  factory ManhuataiBook.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBook(
      bookId: ManhuataiJson.asInt(source['book_id']),
      siteid: ManhuataiJson.asInt(source['siteid']),
      modularType: ManhuataiJson.asInt(source['modular_type']),
      unionType: ManhuataiJson.asInt(source['union_type']),
      unionId: ManhuataiJson.asInt(source['union_id']),
      istop: ManhuataiJson.asInt(source['istop']),
      topNum: ManhuataiJson.asInt(source['top_num']),
      ordernum: ManhuataiJson.asInt(source['ordernum']),
      versionFilter: ManhuataiJson.asInt(source['version_filter']),
      versionNum: ManhuataiJson.asDynamicString(source['version_num']),
      title: ManhuataiJson.asString(source['title']),
      config: ManhuataiBookConfig.fromJson(
        ManhuataiJson.map(source['config']),
      ),
      bookcomicOrder: ManhuataiJson.asInt(source['bookcomic_order']),
      bookcomicImgstyle: ManhuataiJson.asInt(source['bookcomic_imgstyle']),
      advertiseLocation:
          ManhuataiJson.asDynamicString(source['advertise_location']),
      advertiseSdktype: ManhuataiJson.asInt(source['advertise_sdktype']),
      bookDatasource: ManhuataiJson.asInt(source['book_datasource']),
      bookIntellrecommend: ManhuataiJson.asInt(source['book_intellrecommend']),
      comicInfo: ManhuataiJson.maps(source['comic_info'])
          .map(ManhuataiComic.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'book_id': bookId,
        'siteid': siteid,
        'modular_type': modularType,
        'union_type': unionType,
        'union_id': unionId,
        'istop': istop,
        'top_num': topNum,
        'ordernum': ordernum,
        'version_filter': versionFilter,
        'version_num': versionNum,
        'title': title,
        'config': config.toJson(),
        'bookcomic_order': bookcomicOrder,
        'bookcomic_imgstyle': bookcomicImgstyle,
        'advertise_location': advertiseLocation,
        'advertise_sdktype': advertiseSdktype,
        'book_datasource': bookDatasource,
        'book_intellrecommend': bookIntellrecommend,
        'comic_info': comicInfo.map((comic) => comic.toJson()).toList(),
      };
}
