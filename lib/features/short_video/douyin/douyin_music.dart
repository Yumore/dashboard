import 'package:dashboard/features/short_video/douyin/douyin_cover.dart';
import 'package:dashboard/features/short_video/douyin/douyin_json.dart';

/// 作品配乐（`Douyin.Dart` 的 `Music`）。
class DouyinMusic {
  const DouyinMusic({
    this.id = '',
    this.title = '',
    this.author = '',
    this.duration = 0,
    this.playUrl = '',
    this.cover = DouyinCover.empty,
  });

  factory DouyinMusic.fromJson(Object? json) {
    final map = DouyinJson.asMap(json);
    final playUrl = DouyinJson.asMap(map['play_url']);
    return DouyinMusic(
      id: DouyinJson.asString(map['id']),
      title: DouyinJson.asString(map['title']),
      author: DouyinJson.asString(map['author']),
      duration: DouyinJson.asInt(map['duration']),
      playUrl: DouyinJson.firstString(playUrl['url_list']),
      cover: DouyinCover.fromJson(map['cover_medium']),
    );
  }

  final String id;
  final String title;
  final String author;
  final int duration;
  final String playUrl;
  final DouyinCover cover;

  String get displayTitle => title.trim().isEmpty ? '原声' : title.trim();

  String get displayAuthor => author.trim().isEmpty ? '未知' : author.trim();

  String get coverUrl => cover.firstUrl;

  /// 源工程 `video_description.dart` 里的跑马灯文案。
  String get marqueeLabel => '$displayTitle - $displayAuthor';
}
