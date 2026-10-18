import 'package:dashboard/features/movie/eyepetizer/eyepetizer_json.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_play_url.dart';

/// `playInfo` on a 开眼 feed item (`common_item_model.dart:296`).
///
/// This is where the real alternate stream URLs live: the source's
/// `VideoWidget` only ever played `data.playUrl`, so different qualities were
/// downloaded and ignored. The port feeds [urlList] into the host player's
/// source picker instead.
class EyepetizerPlayInfo {
  const EyepetizerPlayInfo({
    this.name = '',
    this.type = '',
    this.url = '',
    this.width = 0,
    this.height = 0,
    this.urlList = const <EyepetizerPlayUrl>[],
  });

  factory EyepetizerPlayInfo.fromJson(Object? json) {
    final map = EyepetizerJson.asMap(json);
    return EyepetizerPlayInfo(
      name: EyepetizerJson.asString(map['name']),
      type: EyepetizerJson.asString(map['type']),
      url: EyepetizerJson.asString(map['url']),
      width: EyepetizerJson.asInt(map['width']),
      height: EyepetizerJson.asInt(map['height']),
      urlList: EyepetizerJson.asMapList(
        map['urlList'],
      ).map(EyepetizerPlayUrl.fromJson).toList(growable: false),
    );
  }

  /// Quality family, e.g. `normal` / `high`.
  final String name;

  /// MIME type, e.g. `video/mp4`.
  final String type;

  /// Direct stream URL when there is no quality list.
  final String url;

  final int width;
  final int height;
  final List<EyepetizerPlayUrl> urlList;
}
