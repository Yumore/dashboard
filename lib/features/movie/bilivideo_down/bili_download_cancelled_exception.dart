/// Thrown when a download is cancelled through its `CancelToken`.
///
/// Dio itself raises `DioExceptionType.cancel`; the downloader and controller
/// speak this type so callers do not have to inspect Dio internals, and so a
/// cancellation is never mistaken for a failure that marks a task complete.
class BiliDownloadCancelledException implements Exception {
  const BiliDownloadCancelledException([this.message = '下载已取消']);

  final String message;

  @override
  String toString() => 'BiliDownloadCancelledException: $message';
}
