import 'package:dashboard/features/movie/youtubedl/youtubedl_audio_only_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_muxed_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_filter.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_info.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_video_only_stream_info.dart';

/// All playable streams of one video, partitioned and sorted by quality.
///
/// Ordering rules (reconstructed from youtube_explode's quality comparators):
/// * video: height desc, then fps desc, then bitrate desc, then itag asc;
/// * muxed: height desc, then bitrate desc, then itag asc;
/// * audio: bitrate desc, then itag asc.
class YoutubeDlStreamManifest {
  YoutubeDlStreamManifest._({
    required this.all,
    required this.muxed,
    required this.videoOnly,
    required this.audioOnly,
    this.unavailableCount = 0,
  });

  factory YoutubeDlStreamManifest(
    Iterable<YoutubeDlStreamInfo> streams, {
    int unavailableCount = 0,
  }) {
    final all = streams.toList(growable: false);
    final muxed = all.whereType<YoutubeDlMuxedStreamInfo>().toList()
      ..sort(_compareMuxed);
    final videoOnly = all.whereType<YoutubeDlVideoOnlyStreamInfo>().toList()
      ..sort(_compareVideoOnly);
    final audioOnly = all.whereType<YoutubeDlAudioOnlyStreamInfo>().toList()
      ..sort(_compareAudioOnly);
    return YoutubeDlStreamManifest._(
      all: List<YoutubeDlStreamInfo>.unmodifiable(<YoutubeDlStreamInfo>[
        ...muxed,
        ...videoOnly,
        ...audioOnly,
      ]),
      muxed: List<YoutubeDlMuxedStreamInfo>.unmodifiable(muxed),
      videoOnly: List<YoutubeDlVideoOnlyStreamInfo>.unmodifiable(videoOnly),
      audioOnly: List<YoutubeDlAudioOnlyStreamInfo>.unmodifiable(audioOnly),
      unavailableCount: unavailableCount,
    );
  }

  /// Every playable stream, grouped muxed -> video only -> audio only.
  final List<YoutubeDlStreamInfo> all;

  final List<YoutubeDlMuxedStreamInfo> muxed;
  final List<YoutubeDlVideoOnlyStreamInfo> videoOnly;
  final List<YoutubeDlAudioOnlyStreamInfo> audioOnly;

  /// Formats that only exposed a `signatureCipher` and were skipped.
  final int unavailableCount;

  bool get isEmpty => all.isEmpty;

  YoutubeDlMuxedStreamInfo? get bestMuxed => muxed.isEmpty ? null : muxed.first;

  YoutubeDlVideoOnlyStreamInfo? get bestVideoOnly =>
      videoOnly.isEmpty ? null : videoOnly.first;

  YoutubeDlAudioOnlyStreamInfo? get bestAudioOnly =>
      audioOnly.isEmpty ? null : audioOnly.first;

  List<YoutubeDlStreamInfo> filter(YoutubeDlStreamFilter filter) {
    switch (filter) {
      case YoutubeDlStreamFilter.all:
        return all;
      case YoutubeDlStreamFilter.videoAudio:
        return muxed;
      case YoutubeDlStreamFilter.videoOnly:
        return videoOnly;
      case YoutubeDlStreamFilter.audioOnly:
        return audioOnly;
    }
  }

  static int _compareMuxed(
    YoutubeDlMuxedStreamInfo a,
    YoutubeDlMuxedStreamInfo b,
  ) {
    final height = b.height.compareTo(a.height);
    if (height != 0) return height;
    final bitrate = b.bitrate.compareTo(a.bitrate);
    if (bitrate != 0) return bitrate;
    return a.itag.compareTo(b.itag);
  }

  static int _compareVideoOnly(
    YoutubeDlVideoOnlyStreamInfo a,
    YoutubeDlVideoOnlyStreamInfo b,
  ) {
    final height = b.height.compareTo(a.height);
    if (height != 0) return height;
    final fps = b.fps.compareTo(a.fps);
    if (fps != 0) return fps;
    final bitrate = b.bitrate.compareTo(a.bitrate);
    if (bitrate != 0) return bitrate;
    return a.itag.compareTo(b.itag);
  }

  static int _compareAudioOnly(
    YoutubeDlAudioOnlyStreamInfo a,
    YoutubeDlAudioOnlyStreamInfo b,
  ) {
    final bitrate = b.bitrate.compareTo(a.bitrate);
    if (bitrate != 0) return bitrate;
    return a.itag.compareTo(b.itag);
  }
}
