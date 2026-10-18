import 'package:dashboard/features/movie/youtubedl/youtubedl_audio_only_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_type.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video_only_stream_info.dart';

/// What the user picked in the stream picker.
///
/// A [single] stream can be written as-is. A [merged] plan pairs a video-only
/// and an audio-only stream: without FFmpeg the queue can only mark it as
/// `needsMuxer`, but the plan still carries the summed size and the intended
/// MP4 container, matching the source app's merge arithmetic.
class YoutubeDlDownloadPlan {
  const YoutubeDlDownloadPlan.single(
    YoutubeDlStreamInfo stream, {
    this.mergedExtension = 'mp4',
  }) : single = stream,
       video = null,
       audio = null;

  const YoutubeDlDownloadPlan.merged({
    required this.video,
    required this.audio,
    this.mergedExtension = 'mp4',
  }) : single = null;

  final YoutubeDlStreamInfo? single;
  final YoutubeDlVideoOnlyStreamInfo? video;
  final YoutubeDlAudioOnlyStreamInfo? audio;

  /// Container used by the source's FFmpeg merge (`.mp4` by default).
  final String mergedExtension;

  bool get requiresMuxer => single == null;

  String get containerExtension {
    if (single != null) return single!.container.extension;
    final normalized = mergedExtension.startsWith('.')
        ? mergedExtension.substring(1)
        : mergedExtension;
    return normalized.isEmpty ? 'mp4' : normalized;
  }

  int get totalBytes {
    if (single != null) return single!.size;
    return (video?.size ?? 0) + (audio?.size ?? 0);
  }

  YoutubeDlStreamType get streamType {
    if (single is YoutubeDlAudioOnlyStreamInfo) {
      return YoutubeDlStreamType.audio;
    }
    return YoutubeDlStreamType.video;
  }

  String get qualityLabel {
    if (single != null) return single!.qualityLabel;
    return '${video?.qualityLabel ?? ''} + ${audio?.qualityLabel ?? ''}';
  }

  Uri? get url => single?.url ?? video?.url;

  Uri? get audioUrl => audio?.url;
}
