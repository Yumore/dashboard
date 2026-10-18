import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// One comic hit of `serachcomic`.
///
/// Source: `lib/models/search_comic.dart` → `Data`.
class ManhuataiSearchComicData {
  const ManhuataiSearchComicData({
    required this.totalViewNum,
    required this.cartoonNewid,
    required this.comicId,
    required this.comicName,
    required this.comicNewid,
  });

  final int totalViewNum;
  final String cartoonNewid;
  final int comicId;
  final String comicName;
  final String comicNewid;

  factory ManhuataiSearchComicData.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiSearchComicData(
      totalViewNum: ManhuataiJson.asInt(source['total_view_num']),
      cartoonNewid: ManhuataiJson.asString(source['cartoon_newid']),
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'total_view_num': totalViewNum,
        'cartoon_newid': cartoonNewid,
        'comic_id': comicId,
        'comic_name': comicName,
        'comic_newid': comicNewid,
      };
}
