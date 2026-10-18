import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 作品计数。源工程只解析 `aweme_id/comment_count/digg_count`；
/// 分享/播放计数在 tiktok share 接口里存在，这里一并保留供展示。
class DouyinStatistics {
  const DouyinStatistics({
    this.awemeId = '',
    this.diggCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.playCount = 0,
  });

  factory DouyinStatistics.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinStatistics(
      awemeId: DouyinJson.asString(map['aweme_id']),
      diggCount: DouyinJson.asInt(map['digg_count']),
      commentCount: DouyinJson.asInt(map['comment_count']),
      shareCount: DouyinJson.asInt(map['share_count']),
      playCount: DouyinJson.asInt(map['play_count']),
    );
  }

  final String awemeId;
  final int diggCount;
  final int commentCount;
  final int shareCount;
  final int playCount;
}
