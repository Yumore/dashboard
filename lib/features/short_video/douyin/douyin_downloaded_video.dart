import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 已保存到本地的视频记录（`shared_preferences` 的
/// `douyin_saved_videos` 键里存 JSON 数组）。
class DouyinDownloadedVideo {
  const DouyinDownloadedVideo({
    required this.awemeId,
    required this.title,
    required this.path,
    required this.savedAt,
  });

  factory DouyinDownloadedVideo.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    return DouyinDownloadedVideo(
      awemeId: DouyinJson.asString(map['aweme_id']),
      title: DouyinJson.asString(map['title']),
      path: DouyinJson.asString(map['path']),
      savedAt: DateTime.tryParse(DouyinJson.asString(map['saved_at'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// 记录损坏时返回 null，由 [DouyinDownloadStore] 跳过。
  static DouyinDownloadedVideo? tryParse(Object? json) {
    if (json is! Map && json is! String) {
      return null;
    }
    final map = DouyinJson.asMap(json);
    final path = DouyinJson.asString(map['path']);
    if (path.isEmpty) {
      return null;
    }
    return DouyinDownloadedVideo.fromJson(map);
  }

  final String awemeId;
  final String title;
  final String path;
  final DateTime savedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'aweme_id': awemeId,
      'title': title,
      'path': path,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}
