import 'package:dashboard/features/movie/youtubedl/youtubedl_bytes.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_duration.dart';

/// Progress, average speed and ETA arithmetic for one download.
class YoutubeDlProgress {
  const YoutubeDlProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.elapsed,
    this.completed = false,
  });

  final int downloadedBytes;

  /// `0` when YouTube did not report a content length.
  final int totalBytes;

  final Duration elapsed;
  final bool completed;

  /// Source parity: `(downloadedBytes / totalSize * 100).floor()`, clamped to
  /// `0..100` so an over-reporting server cannot render a 140% bar.
  int get percent {
    if (completed) return 100;
    if (totalBytes <= 0) return 0;
    final value = (downloadedBytes / totalBytes * 100).floor();
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }

  bool get isIndeterminate => totalBytes <= 0 && !completed;

  double get bytesPerSecond {
    final millis = elapsed.inMilliseconds;
    if (millis <= 0) return 0;
    return downloadedBytes * 1000 / millis;
  }

  Duration get eta {
    if (completed) return Duration.zero;
    final speed = bytesPerSecond;
    if (speed <= 0 || totalBytes <= downloadedBytes) return Duration.zero;
    final remainingSeconds = ((totalBytes - downloadedBytes) / speed).ceil();
    return Duration(seconds: remainingSeconds);
  }

  String get speedLabel => '${YoutubeDlBytes.format(bytesPerSecond.round())}/s';

  String get etaLabel => YoutubeDlDuration.format(eta);
}
