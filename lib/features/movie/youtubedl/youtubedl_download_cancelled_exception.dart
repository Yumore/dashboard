/// Thrown by a [YoutubeDlStreamSink] when its cancellation token fires.
class YoutubeDlDownloadCancelledException implements Exception {
  const YoutubeDlDownloadCancelledException();

  @override
  String toString() => 'YoutubeDlDownloadCancelledException';
}
