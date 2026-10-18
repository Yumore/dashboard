import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One album (`book`) entry of `getbookinfo_sys`.
///
/// Source: `lib/models/get_book_info_by_id.dart` → `Book_list`.
class ManhuataiBookInfoEntry {
  const ManhuataiBookInfoEntry({
    required this.id,
    required this.comicName,
    required this.productId,
    required this.comicFeature,
    required this.loadType,
    required this.imgUrl,
    required this.nofollow,
    required this.sortNum,
    required this.url,
    required this.comicId,
    required this.pageId,
    required this.isdisable,
    required this.comicType,
    required this.cartoonName,
    required this.newCartoonId,
    required this.newCartoonName,
    required this.authorName,
    required this.totalViewNum,
    required this.comicNewid,
    required this.latestCartoonTopicId,
    required this.cartoonDesc,
    required this.cartoonTopicName,
    required this.chapterFeature,
    required this.fontColor,
    required this.fontSize,
    required this.borderColor,
    required this.borderSize,
    required this.featurePosition,
    required this.chapterImageAddr,
    required this.cartoonStatus,
    required this.updateTime,
  });

  final int id;
  final String comicName;
  final String productId;
  final String comicFeature;
  final int loadType;
  final String imgUrl;
  final int nofollow;
  final int sortNum;
  final String url;
  final int comicId;
  final String pageId;
  final int isdisable;

  /// Display tags such as `["热血", "冒险"]`.
  final List<String> comicType;
  final String cartoonName;
  final String newCartoonId;
  final String newCartoonName;
  final String authorName;
  final String totalViewNum;
  final String comicNewid;
  final int latestCartoonTopicId;
  final String cartoonDesc;
  final String cartoonTopicName;
  final String chapterFeature;
  final String fontColor;
  final int fontSize;
  final String borderColor;
  final int borderSize;
  final String featurePosition;
  final String chapterImageAddr;
  final String cartoonStatus;
  final int updateTime;

  factory ManhuataiBookInfoEntry.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBookInfoEntry(
      id: ManhuataiJson.asInt(source['id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      productId: ManhuataiJson.asDynamicString(source['product_id']),
      comicFeature: ManhuataiJson.asString(source['comic_feature']),
      loadType: ManhuataiJson.asInt(source['load_type']),
      imgUrl: ManhuataiJson.asString(source['img_url']),
      nofollow: ManhuataiJson.asInt(source['nofollow']),
      sortNum: ManhuataiJson.asInt(source['sort_num']),
      url: ManhuataiJson.asString(source['url']),
      comicId: ManhuataiJson.asInt(source['comic_id']),
      pageId: ManhuataiJson.asDynamicString(source['page_id']),
      isdisable: ManhuataiJson.asInt(source['isdisable']),
      comicType: ManhuataiJson.asStringList(source['comic_type']),
      cartoonName: ManhuataiJson.asString(source['cartoon_name']),
      newCartoonId: ManhuataiJson.asDynamicString(source['new_cartoon_id']),
      newCartoonName: ManhuataiJson.asString(source['new_cartoon_name']),
      authorName: ManhuataiJson.asString(source['author_name']),
      totalViewNum: ManhuataiJson.asDynamicString(source['total_view_num']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
      latestCartoonTopicId:
          ManhuataiJson.asInt(source['latest_cartoon_topic_id']),
      cartoonDesc: ManhuataiJson.asString(source['cartoon_desc']),
      cartoonTopicName: ManhuataiJson.asString(source['cartoon_topic_name']),
      chapterFeature: ManhuataiJson.asString(source['chapter_feature']),
      fontColor: ManhuataiJson.asString(source['font_color']),
      fontSize: ManhuataiJson.asInt(source['font_size']),
      borderColor: ManhuataiJson.asString(source['border_color']),
      borderSize: ManhuataiJson.asInt(source['border_size']),
      featurePosition: ManhuataiJson.asString(source['feature_position']),
      chapterImageAddr: ManhuataiJson.asString(source['chapter_image_addr']),
      cartoonStatus: ManhuataiJson.asString(source['cartoon_status']),
      updateTime: ManhuataiJson.asInt(source['update_time']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'comic_name': comicName,
        'product_id': productId,
        'comic_feature': comicFeature,
        'load_type': loadType,
        'img_url': imgUrl,
        'nofollow': nofollow,
        'sort_num': sortNum,
        'url': url,
        'comic_id': comicId,
        'page_id': pageId,
        'isdisable': isdisable,
        'comic_type': comicType,
        'cartoon_name': cartoonName,
        'new_cartoon_id': newCartoonId,
        'new_cartoon_name': newCartoonName,
        'author_name': authorName,
        'total_view_num': totalViewNum,
        'comic_newid': comicNewid,
        'latest_cartoon_topic_id': latestCartoonTopicId,
        'cartoon_desc': cartoonDesc,
        'cartoon_topic_name': cartoonTopicName,
        'chapter_feature': chapterFeature,
        'font_color': fontColor,
        'font_size': fontSize,
        'border_color': borderColor,
        'border_size': borderSize,
        'feature_position': featurePosition,
        'chapter_image_addr': chapterImageAddr,
        'cartoon_status': cartoonStatus,
        'update_time': updateTime,
      };
}
