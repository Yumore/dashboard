import 'package:dashboard/features/comic/manhuatai/manhuatai_json.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_search_comic_data.dart';

/// Response wrapper of `serachcomic`.
///
/// Source: `lib/models/search_comic.dart` → `SearchComic`.
class ManhuataiSearchComic {
  const ManhuataiSearchComic({
    required this.status,
    required this.msg,
    required this.data,
  });

  final int status;
  final String msg;
  final List<ManhuataiSearchComicData> data;

  static const ManhuataiSearchComic empty = ManhuataiSearchComic(
    status: 0,
    msg: '',
    data: <ManhuataiSearchComicData>[],
  );

  factory ManhuataiSearchComic.fromJson(Map<String, dynamic> json) {
    final source = ManhuataiJson.map(json);
    return ManhuataiSearchComic(
      status: ManhuataiJson.asInt(source['status']),
      msg: ManhuataiJson.asString(source['msg']),
      data: ManhuataiJson.maps(source['data'])
          .map(ManhuataiSearchComicData.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'status': status,
        'msg': msg,
        'data': data.map((item) => item.toJson()).toList(),
      };
}
