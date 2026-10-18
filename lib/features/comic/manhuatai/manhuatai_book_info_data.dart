import 'package:dashboard/features/comic/manhuatai/manhuatai_book_info_entry.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// Album payload of `getbookinfo_sys`.
///
/// Source: `lib/models/get_book_info_by_id.dart` → `Data`.
class ManhuataiBookInfoData {
  const ManhuataiBookInfoData({
    required this.bookId,
    required this.bookName,
    required this.summary,
    required this.shoucang,
    required this.share,
    required this.createtime,
    required this.updatetime,
    required this.userId,
    required this.imgUrl,
    required this.shareTitle,
    required this.shareSummary,
    required this.bookList,
  });

  final int bookId;
  final String bookName;
  final String summary;
  final String shoucang;
  final String share;
  final int createtime;
  final int updatetime;
  final int userId;
  final String imgUrl;
  final String shareTitle;
  final String shareSummary;
  final List<ManhuataiBookInfoEntry> bookList;

  static const ManhuataiBookInfoData empty = ManhuataiBookInfoData(
    bookId: 0,
    bookName: '',
    summary: '',
    shoucang: '',
    share: '',
    createtime: 0,
    updatetime: 0,
    userId: 0,
    imgUrl: '',
    shareTitle: '',
    shareSummary: '',
    bookList: <ManhuataiBookInfoEntry>[],
  );

  factory ManhuataiBookInfoData.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiBookInfoData(
      bookId: ManhuataiJson.asInt(source['book_id']),
      bookName: ManhuataiJson.asString(source['book_name']),
      summary: ManhuataiJson.asString(source['summary']),
      shoucang: ManhuataiJson.asDynamicString(source['shoucang']),
      share: ManhuataiJson.asDynamicString(source['share']),
      createtime: ManhuataiJson.asInt(source['createtime']),
      updatetime: ManhuataiJson.asInt(source['updatetime']),
      userId: ManhuataiJson.asInt(source['user_id']),
      imgUrl: ManhuataiJson.asString(source['img_url']),
      shareTitle: ManhuataiJson.asString(source['share_title']),
      shareSummary: ManhuataiJson.asString(source['share_summary']),
      bookList: ManhuataiJson.maps(source['book_list'])
          .map(ManhuataiBookInfoEntry.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'book_id': bookId,
        'book_name': bookName,
        'summary': summary,
        'shoucang': shoucang,
        'share': share,
        'createtime': createtime,
        'updatetime': updatetime,
        'user_id': userId,
        'img_url': imgUrl,
        'share_title': shareTitle,
        'share_summary': shareSummary,
        'book_list': bookList.map((item) => item.toJson()).toList(),
      };
}
