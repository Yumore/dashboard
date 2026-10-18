import 'package:dashboard/features/short_video/douyin/douyin_cover.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';
import 'package:dashboard/features/short_video/douyin/douyin_play_addr.dart';

/// 作品视频信息（`Douyin.Dart` 的 `Video`）。
class DouyinVideo {
  const DouyinVideo({
    this.width = 0,
    this.height = 0,
    this.ratio = '',
    this.duration = 0,
    this.vid = '',
    this.hasWatermark = false,
    this.cover = DouyinCover.empty,
    this.playAddr = const DouyinPlayAddr(),
  });

  factory DouyinVideo.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinVideo(
      width: DouyinJson.asInt(map['width']),
      height: DouyinJson.asInt(map['height']),
      ratio: DouyinJson.asString(map['ratio']),
      duration: DouyinJson.asInt(map['duration']),
      vid: DouyinJson.asString(map['vid']),
      hasWatermark: DouyinJson.asBool(map['has_watermark']),
      cover: DouyinCover.fromJson(map['cover']),
      playAddr: DouyinPlayAddr.fromJson(map['play_addr']),
    );
  }

  final int width;
  final int height;
  final String ratio;
  final int duration;
  final String vid;
  final bool hasWatermark;
  final DouyinCover cover;
  final DouyinPlayAddr playAddr;

  String get coverUrl => cover.firstUrl;

  /// 宽高比，源工程播放器固定 `aspectRatio: 0.656`；
  /// 有真实宽高时按真实比例裁切。
  double get aspectRatio {
    if (width > 0 && height > 0) {
      return width / height;
    }
    return 0.656;
  }

  int get durationSeconds => duration > 1000 ? duration ~/ 1000 : duration;
}
