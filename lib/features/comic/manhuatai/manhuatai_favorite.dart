import 'package:dashboard/features/comic/manhuatai/manhuatai_comic.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';

/// A locally persisted favourite ("我的收藏").
///
/// The source had a server-side collect list (`setusercollect` +
/// `getuserrecord`); this port persists the same essential fields locally via
/// `shared_preferences`, which works without login.
class ManhuataiFavorite {
  const ManhuataiFavorite({
    required this.comicId,
    required this.comicName,
    required this.imgUrl,
    this.comicNewid = '',
    this.addedAt = 0,
  });

  final int comicId;
  final String comicName;
  final String imgUrl;
  final String comicNewid;
  final int addedAt;

  factory ManhuataiFavorite.fromComic(ManhuataiComic comic) {
    return ManhuataiFavorite(
      comicId: comic.comicId,
      comicName: comic.comicName,
      imgUrl: ManhuataiImageUrl.cover(
        comicId: comic.comicId,
        imgUrl: comic.imgUrl,
      ),
      comicNewid: '',
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory ManhuataiFavorite.fromDetail(ManhuataiDetail detail, {int comicId = 0}) {
    return ManhuataiFavorite(
      comicId: comicId,
      comicName: detail.comicName,
      imgUrl: ManhuataiImageUrl.cover(comicId: comicId),
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory ManhuataiFavorite.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiFavorite(
      comicId: ManhuataiJson.asInt(source['comic_id']),
      comicName: ManhuataiJson.asString(source['comic_name']),
      imgUrl: ManhuataiJson.asString(source['img_url']),
      comicNewid: ManhuataiJson.asString(source['comic_newid']),
      addedAt: ManhuataiJson.asInt(source['added_at']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'comic_id': comicId,
        'comic_name': comicName,
        'img_url': imgUrl,
        'comic_newid': comicNewid,
        'added_at': addedAt,
      };
}
