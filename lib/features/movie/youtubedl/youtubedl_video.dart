import 'package:dashboard/features/movie/youtubedl/youtubedl_duration.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_json.dart';

/// The video metadata shown in search results and download tasks.
class YoutubeDlVideo {
  const YoutubeDlVideo({
    required this.id,
    required this.title,
    required this.author,
    required this.duration,
    required this.thumbnail,
  });

  factory YoutubeDlVideo.fromVideoDetails(Map<String, dynamic> json) {
    final id = YoutubeDlJson.asString(json['videoId']);
    final rawTitle = YoutubeDlJson.asString(json['title']);
    return YoutubeDlVideo(
      id: id,
      title: rawTitle.isEmpty ? id : rawTitle,
      author: YoutubeDlJson.asString(json['author']),
      duration: Duration(seconds: YoutubeDlJson.asInt(json['lengthSeconds'])),
      thumbnail: YoutubeDlJson.thumbnailUrl(json['thumbnail']),
    );
  }

  final String id;
  final String title;
  final String author;
  final Duration duration;
  final String thumbnail;

  String get durationLabel => YoutubeDlDuration.format(duration);

  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
}
