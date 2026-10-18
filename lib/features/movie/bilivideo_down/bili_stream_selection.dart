import 'package:dashboard/features/movie/bilivideo_down/bili_dash.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_dash_stream.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_format.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_play_info.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_quality.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_video_stream.dart';

/// Pure stream-selection rules for a play-url response.
///
/// Split out of the controller so the rules are testable without a Dio call:
/// which qualities to offer, which container to pick by default, and how a
/// quality/format pair maps onto one concrete [BiliVideoStream].
class BiliStreamSelection {
  const BiliStreamSelection({
    required this.qualities,
    required this.formats,
    required this.defaultQuality,
  });

  /// Offerable qualities, ordered as the server reported them (highest first),
  /// falling back to [biliFallbackQualities] when `accept_quality` is absent —
  /// which is what the source's `platform=html5` response does.
  final List<int> qualities;

  /// Containers this response can be downloaded as.
  final List<BiliDownloadFormat> formats;

  /// Quality selected when the user has not picked one.
  final int defaultQuality;

  bool get isEmpty => formats.isEmpty;

  /// Container selected when the user has not picked one: progressive `durl`
  /// first, because that is what the source app always used.
  BiliDownloadFormat? get defaultFormat =>
      formats.isEmpty ? null : formats.first;

  static BiliStreamSelection fromPlayInfo(BiliPlayInfo info) =>
      BiliStreamSelection(
        qualities: qualitiesOf(info),
        formats: formatsOf(info),
        defaultQuality: defaultQualityOf(info),
      );

  /// Qualities to offer for [info].
  static List<int> qualitiesOf(BiliPlayInfo info) {
    final seen = <int>{};
    final accepted = <int>[
      for (final quality in info.acceptQuality)
        if (quality > 0 && seen.add(quality)) quality,
    ];
    if (accepted.isNotEmpty) return accepted;
    if (info.quality > 0) {
      return <int>[
        info.quality,
        ...biliFallbackQualities.where((q) => q != info.quality),
      ];
    }
    return List<int>.of(biliFallbackQualities);
  }

  /// Containers [info] can actually be downloaded as.
  static List<BiliDownloadFormat> formatsOf(BiliPlayInfo info) =>
      <BiliDownloadFormat>[
        if (info.hasProgressiveStream) BiliDownloadFormat.flv,
        if (info.hasDashStream) BiliDownloadFormat.dash,
      ];

  /// `qn: 80` when the server offers it, otherwise its own first offer.
  static int defaultQualityOf(BiliPlayInfo info) {
    final qualities = qualitiesOf(info);
    if (qualities.isEmpty) return biliDefaultQuality;
    if (qualities.contains(biliDefaultQuality)) return biliDefaultQuality;
    return qualities.first;
  }

  /// Resolves one downloadable stream, or `null` when the response carries none.
  static BiliVideoStream? resolve(
    BiliPlayInfo info, {
    int? quality,
    BiliDownloadFormat? format,
  }) {
    final available = formatsOf(info);
    if (available.isEmpty) return null;
    var chosen = format ?? available.first;
    if (!available.contains(chosen)) chosen = available.first;
    if (chosen == BiliDownloadFormat.dash) {
      final dash = resolveDash(info, quality ?? defaultQualityOf(info));
      if (dash != null) return dash;
    }
    if (available.contains(BiliDownloadFormat.flv)) {
      return resolveProgressive(info);
    }
    return resolveDash(info, quality ?? defaultQualityOf(info));
  }

  /// The progressive stream the source app downloaded: `durl[0]`.
  static BiliVideoStream? resolveProgressive(BiliPlayInfo info) {
    final segment = info.primarySegment;
    if (segment == null) return null;
    return BiliVideoStream(
      format: BiliDownloadFormat.flv,
      quality: info.quality,
      url: segment.url,
      durationMs: segment.length > 0 ? segment.length : info.timelength,
      size: segment.size,
      segmentCount: info.segmentCount,
    );
  }

  /// Builds a DASH stream for [quality], attaching the best audio track.
  static BiliVideoStream? resolveDash(BiliPlayInfo info, int quality) {
    final dash = info.dash;
    if (dash == null) return null;
    final video = pickDashVideo(dash, quality);
    if (video == null) return null;
    final audio = pickDashAudio(dash);
    return BiliVideoStream(
      format: BiliDownloadFormat.dash,
      quality: video.id > 0 ? video.id : quality,
      url: video.baseUrl,
      durationMs: (dash.duration * 1000).round(),
      size: 0,
      audioUrl: audio?.baseUrl,
    );
  }

  /// Exact quality when present, else the closest one, preferring the higher
  /// code on a tie.
  static BiliDashStream? pickDashVideo(BiliDash dash, int quality) {
    final tracks = dash.video.where((track) => track.isPlayable).toList();
    if (tracks.isEmpty) return null;
    for (final track in tracks) {
      if (track.id == quality) return track;
    }
    tracks.sort((a, b) {
      final byDistance = (a.id - quality).abs().compareTo(
        (b.id - quality).abs(),
      );
      return byDistance != 0 ? byDistance : b.id.compareTo(a.id);
    });
    return tracks.first;
  }

  /// Highest-bandwidth audio track; the source never needed one, but a DASH
  /// download is silent without it.
  static BiliDashStream? pickDashAudio(BiliDash dash) {
    final tracks = dash.audio.where((track) => track.isPlayable).toList();
    if (tracks.isEmpty) return null;
    tracks.sort((a, b) => b.bandwidth.compareTo(a.bandwidth));
    return tracks.first;
  }

  /// Whether [info] can be downloaded at all.
  static bool isPlayable(BiliPlayInfo info) => formatsOf(info).isNotEmpty;

  /// Label for [quality], e.g. `1080P 高清`.
  static String qualityLabel(int quality) => biliQualityLabel(quality);
}
