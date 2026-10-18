import 'package:dashboard/features/movie/bilivideo_down/bili_dash_stream.dart';

/// The `dash` block of a `fnval`-enabled play-url response: separate video and
/// audio track lists that the player has to mux.
class BiliDash {
  const BiliDash({
    required this.duration,
    required this.minBufferTime,
    required this.video,
    required this.audio,
  });

  /// Duration in **seconds** (`dash.duration`), unlike `durl.length` which is
  /// in milliseconds.
  final double duration;
  final double minBufferTime;
  final List<BiliDashStream> video;
  final List<BiliDashStream> audio;

  bool get hasVideo => video.any((track) => track.isPlayable);
  bool get hasAudio => audio.any((track) => track.isPlayable);

  factory BiliDash.fromJson(Map<String, dynamic> json) => BiliDash(
    duration: _asDouble(json['duration']),
    minBufferTime: _asDouble(json['minBufferTime'] ?? json['min_buffer_time']),
    video: _streams(json['video']),
    audio: _streams(json['audio']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'duration': duration,
    'minBufferTime': minBufferTime,
    'video': <dynamic>[for (final track in video) track.toJson()],
    'audio': <dynamic>[for (final track in audio) track.toJson()],
  };
}

List<BiliDashStream> _streams(Object? raw) => <BiliDashStream>[
  for (final entry in (raw as List? ?? const <Object?>[]))
    if (entry is Map) BiliDashStream.fromJson(Map<String, dynamic>.from(entry)),
];

double _asDouble(Object? value) =>
    value is double ? value : double.tryParse('$value') ?? 0;
