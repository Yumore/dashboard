import 'package:dashboard/features/movie/youtubedl/youtubedl_cancellation_token.dart';

/// Byte-writing seam for downloads.
///
/// Production uses `DioYouTubeDlStreamSink`; tests inject in-memory fakes so no
/// socket or filesystem is touched.
abstract class YoutubeDlStreamSink {
  /// Writes [url] to [path], reporting cumulative bytes through [onProgress].
  ///
  /// Must complete normally on success and throw
  /// `YoutubeDlDownloadCancelledException` once [cancellation] fires.
  Future<void> write({
    required Uri url,
    required String path,
    required int totalBytes,
    required YoutubeDlCancellationToken cancellation,
    required void Function(int received) onProgress,
  });

  Future<bool> exists(String path);

  Future<void> delete(String path);
}
