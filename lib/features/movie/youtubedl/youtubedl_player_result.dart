import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_manifest.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video.dart';

/// Video metadata together with the streams extracted from `playerResponse`.
class YoutubeDlPlayerResult {
  const YoutubeDlPlayerResult({required this.video, required this.manifest});

  final YoutubeDlVideo video;
  final YoutubeDlStreamManifest manifest;
}
