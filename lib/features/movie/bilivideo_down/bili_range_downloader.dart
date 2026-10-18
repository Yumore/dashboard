import 'dart:io';

import 'package:dashboard/features/movie/bilivideo_down/bili_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_download_exception.dart';
import 'package:dio/dio.dart';
import 'package:dashboard/features/movie/bilivideo_down/bili_file_paths.dart';

/// Progress callback, identical in shape to the source app's
/// `typedef ProgressCallback = void Function(int received, int total)`.
typedef BiliProgressCallback = void Function(int received, int total);

/// Multi-threaded HTTP range downloader.
///
/// Ports `RangeDownloadUtil.downloadWithChunks` from the source app
/// (`lib/util/range_download_util.dart`) with the same wire behaviour and the
/// same temp-file scheme, and fixes three edge cases the source mishandled:
///
/// 1. the number of data chunks is now `min(needed, maxChunk)` instead of always
///    `maxChunk`, so a small file no longer produces an inverted byte range;
/// 2. a 206 whose `content-range` total cannot be parsed falls back to a single
///    whole-file download instead of crashing on a null;
/// 3. a data chunk answered with `200` (i.e. the server ignored `Range`) is
///    reported as an error instead of being silently spliced into the file;
/// 4. a chunk body shorter than the range it asked for — or a parked prefix
///    sitting next to an already-complete tail — is reported as an error /
///    refetched, instead of being spliced in short or duplicated.
///
/// Ranges are inclusive on both ends (`bytes=102-550`), so the concatenated
/// output is exactly `total` bytes.
///
/// Temp files: `"$savePath"temp0` holds the first chunk, `temp1…tempN` the rest,
/// and a chunk cut short keeps its bytes on disk (dio is called with
/// `deleteOnError: false`) so a retry resumes from the byte offset already
/// stored. Because dio truncates the file it opens, a resumed chunk first moves
/// its partial bytes aside as `"…tempN_pre"` and downloads only the missing
/// tail; the two halves are stitched together once the tail arrives. The final
/// [download] target file is only written by the last merge, so a cancellation
/// can never leave a truncated file at the destination.
class BiliRangeDownloader {
  BiliRangeDownloader({
    required Dio dio,
    this.firstChunkSize = 102,
    this.maxChunk = 2,
  }) : assert(firstChunkSize > 0),
       assert(maxChunk > 0),
       _dio = dio;

  final Dio _dio;

  /// Size of the probe/leading chunk, the source app's `firstChunkSize`.
  final int firstChunkSize;

  /// Maximum number of parallel range requests, the source app's `maxChunk`
  /// (its `downloading_controller` never passed anything else, so it was 2).
  final int maxChunk;

  final Map<int, int> _received = <int, int>{};
  final Map<int, int> _initial = <int, int>{};
  int _expectedTotal = 0;
  BiliProgressCallback? _onProgress;

  /// Downloads [url] into [savePath] and returns the number of bytes written.
  ///
  /// * [headers] are sent on every request (the module passes bilibili's
  ///   `Referer`/`User-Agent`).
  /// * [onProgress] reports `(bytesOnDisk, totalBytes)`; `totalBytes` is `0`
  ///   while the server has not reported a size.
  /// * [resume] `true` (the default) reuses leftover temp files; `false` starts
  ///   from a clean slate.
  /// * Cancellation through [cancelToken] throws
  ///   [BiliDownloadCancelledException], leaving temp files (never the final
  ///   file) for a later resume.
  ///
  /// An instance runs one download at a time; concurrent calls would share the
  /// progress bookkeeping.
  Future<int> download({
    required String url,
    required String savePath,
    Map<String, String> headers = const <String, String>{},
    BiliProgressCallback? onProgress,
    CancelToken? cancelToken,
    bool resume = true,
  }) async {
    _received.clear();
    _initial.clear();
    _expectedTotal = 0;
    _onProgress = onProgress;
    _throwIfCancelled(cancelToken);

    final parent = Directory(BiliFilePaths.dirname(savePath));
    if (!parent.existsSync()) {
      await parent.create(recursive: true);
    }

    final probe = await _downloadChunk(
      url: url,
      savePath: savePath,
      no: 0,
      start: 0,
      end: firstChunkSize - 1,
      isMerge: false,
      headers: headers,
      cancelToken: cancelToken,
      resume: resume,
    );

    final status = probe.statusCode ?? 0;
    if (status == HttpStatus.partialContent) {
      final total = _totalFromContentRange(
        probe.headers.value('content-range'),
      );
      if (total == null || total <= 0) {
        return _downloadWhole(
          url: url,
          savePath: savePath,
          headers: headers,
          cancelToken: cancelToken,
        );
      }
      _expectedTotal = total;
      // The data chunks start after the bytes actually on disk, not after
      // `firstChunkSize`: when the server answers the probe with a short body,
      // the missing `firstChunkSize - lead` bytes would otherwise be skipped and
      // the merged file would come out short.
      final lead = _lengthOf('${savePath}temp0');
      _received[0] = lead;
      _initial[0] = lead;
      _emitProgress();

      final reserved = total - lead;
      var chunkCount = reserved <= 0
          ? 1
          : (reserved / firstChunkSize).ceil() + 1;
      var chunkSize = firstChunkSize;
      if (chunkCount > maxChunk + 1) {
        chunkCount = maxChunk + 1;
        chunkSize = (reserved / maxChunk).ceil();
      }
      if (chunkSize < 1) chunkSize = 1;

      final dataChunks = chunkCount - 1;
      final futures = <Future<Response>>[];
      for (var i = 0; i < dataChunks; i++) {
        final start = lead + i * chunkSize;
        // Ranges are inclusive on both ends, so the final chunk stops one byte
        // before `total`; merged output is then exactly `total` bytes.
        final end = (i == dataChunks - 1) ? total - 1 : start + chunkSize - 1;
        futures.add(
          _downloadChunk(
            url: url,
            savePath: savePath,
            no: i + 1,
            start: start,
            end: end,
            isMerge: true,
            headers: headers,
            cancelToken: cancelToken,
            resume: resume,
          ),
        );
      }
      await Future.wait(futures);
      _throwIfCancelled(cancelToken);
      await _mergeTempFiles(savePath: savePath, chunkCount: chunkCount);
      final written = _lengthOf(savePath);
      _emitProgress(written: written);
      return written;
    }

    if (status == HttpStatus.ok) {
      // `Range` unsupported: the server streamed the whole body into temp0, so
      // finish by promoting it to the destination.
      await _mergeTempFiles(savePath: savePath, chunkCount: 1);
      _expectedTotal = 0;
      final written = _lengthOf(savePath);
      _emitProgress(written: written);
      return written;
    }

    throw BiliDownloadException(
      'Unhandled response status code: $status',
      statusCode: status,
      url: url,
    );
  }

  /// One range request for bytes `[start, end]` (inclusive), resuming whatever
  /// bytes of that chunk already exist on disk.
  Future<Response> _downloadChunk({
    required String url,
    required String savePath,
    required int no,
    required int start,
    required int end,
    required bool isMerge,
    required Map<String, String> headers,
    required CancelToken? cancelToken,
    required bool resume,
  }) async {
    _throwIfCancelled(cancelToken);
    final path = '${savePath}temp$no';
    final prepared = await _prepareResume(
      path: path,
      start: start,
      end: end,
      isMerge: isMerge,
      resume: resume,
    );
    _initial[no] = prepared.initial;
    _received[no] = prepared.initial;

    final Response response;
    try {
      response = await _dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          _received[no] = prepared.initial + received;
          _emitProgress();
        },
        options: Options(
          headers: <String, String>{
            ...headers,
            'range': 'bytes=${prepared.start}-${prepared.end}',
          },
        ),
        deleteOnError: false,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) ||
          error.type == DioExceptionType.cancel) {
        throw const BiliDownloadCancelledException();
      }
      rethrow;
    }

    // dio truncates the file it opens, so what is on disk now is exactly what
    // this request wrote.
    final writtenByRequest = _lengthOf(path);
    if ((response.statusCode ?? 0) == HttpStatus.ok && isMerge) {
      throw BiliDownloadException(
        'server ignored the Range header for chunk $no',
        statusCode: response.statusCode,
        url: url,
      );
    }
    if (isMerge) {
      // `prepared.start - prepared.initial` is the chunk's original start, so
      // the difference is the full chunk size even after a resumed request.
      final chunkTotal = prepared.end - (prepared.start - prepared.initial) + 1;
      final onDisk = prepared.initial + writtenByRequest;
      if (onDisk < chunkTotal) {
        // A short body (truncated connection, or a `content-range` total that
        // overstates the real file) must not be spliced in as if it were whole.
        throw BiliDownloadException(
          'chunk $no ended after $onDisk of $chunkTotal bytes',
          statusCode: response.statusCode,
          url: url,
        );
      }
      final pre = File('${path}_pre');
      if (pre.existsSync()) {
        // The tail is complete: stitch the parked prefix and the tail together.
        await _mergeFiles(file1: pre, file2: File(path), target: File(path));
      }
    }
    _received[no] = prepared.initial + writtenByRequest;
    _emitProgress();
    _throwIfCancelled(cancelToken);
    return response;
  }

  /// Resume bookkeeping for [path]: returns the byte range still to request and
  /// how many bytes of it are already valid on disk.
  Future<({int start, int end, int initial})> _prepareResume({
    required String path,
    required int start,
    required int end,
    required bool isMerge,
    required bool resume,
  }) async {
    final target = File(path);
    final pre = File('${path}_pre');
    if (!target.existsSync() && pre.existsSync()) {
      // A previous attempt parked this chunk's prefix and then died before the
      // tail file appeared. Those bytes are still valid, so restore them as the
      // working file instead of downloading the prefix a second time (which
      // would duplicate it in the merged output).
      await pre.rename(path);
    }
    if (!target.existsSync()) {
      return (start: start, end: end, initial: 0);
    }
    if (!resume || !isMerge) {
      // dio truncates the file it opens; chunk 0 has no `_pre` parking (like the
      // source app), so a partial leading chunk is always refetched in full.
      await target.delete();
      if (pre.existsSync()) await pre.delete();
      return (start: start, end: end, initial: 0);
    }
    if (target.lengthSync() <= 0 && pre.existsSync()) {
      // Empty tail beside a parked prefix: keep the prefix's bytes rather than
      // throwing them away on every retry.
      await target.delete();
      await pre.rename(path);
    }
    final length = target.lengthSync();
    final preLength = pre.existsSync() ? pre.lengthSync() : 0;
    if (length <= 0 || length + preLength >= end - start + 1) {
      // Empty, or already complete (stale) once its prefix is counted: refetch
      // it whole so no stale bytes can be spliced into the output.
      await target.delete();
      if (pre.existsSync()) await pre.delete();
      return (start: start, end: end, initial: 0);
    }
    var nextStart = start + length;
    var initial = length;
    if (preLength > 0) {
      // Park the partial tail at the end of the prefix; the freshly downloaded
      // tail then starts exactly at `nextStart`.
      initial += preLength;
      nextStart += preLength;
      await _mergeFiles(file1: pre, file2: target, target: pre);
    } else {
      await target.rename('${path}_pre');
    }
    return (start: nextStart, end: end, initial: initial);
  }

  /// Appends [file2] onto [file1] and leaves the result at [target].
  Future<void> _mergeFiles({
    required File file1,
    required File file2,
    required File target,
  }) async {
    final sink = file1.openWrite(mode: FileMode.writeOnlyAppend);
    try {
      await sink.addStream(file2.openRead());
    } finally {
      await sink.flush();
      await sink.close();
    }
    if (file2.existsSync()) await file2.delete();
    if (file1.path != target.path) await file1.rename(target.path);
  }

  /// Concatenates `temp0…temp(n-1)` into [savePath].
  Future<void> _mergeTempFiles({
    required String savePath,
    required int chunkCount,
  }) async {
    final first = File('${savePath}temp0');
    if (!first.existsSync()) {
      throw BiliDownloadException('temp chunk missing: ${first.path}');
    }
    final sink = first.openWrite(mode: FileMode.writeOnlyAppend);
    try {
      for (var i = 1; i < chunkCount; i++) {
        final part = File('${savePath}temp$i');
        if (!part.existsSync()) continue;
        await sink.addStream(part.openRead());
        await part.delete();
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    final destination = File(savePath);
    if (destination.existsSync()) await destination.delete();
    await first.rename(savePath);
  }

  /// Single whole-file download, used both when the server ignores `Range` and
  /// when a 206 carries no usable total.
  Future<int> _downloadWhole({
    required String url,
    required String savePath,
    required Map<String, String> headers,
    required CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          _expectedTotal = total;
          _onProgress?.call(received, total);
        },
        options: Options(headers: <String, String>{...headers}),
        deleteOnError: true,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error) ||
          error.type == DioExceptionType.cancel) {
        throw const BiliDownloadCancelledException();
      }
      rethrow;
    }
    _throwIfCancelled(cancelToken);
    return _lengthOf(savePath);
  }

  void _emitProgress({int? written}) {
    final total = written ?? _received.values.fold<int>(0, (sum, v) => sum + v);
    _onProgress?.call(total, _expectedTotal);
  }

  /// Removes the temp files a download may have left behind, following the
  /// `"$savePath"tempN` / `"$savePath"tempN_pre` convention of [download].
  ///
  /// Returns the number of files deleted. The final file is left alone.
  static int deletePartialArtifacts(String savePath) {
    if (savePath.isEmpty) return 0;
    final directory = Directory(BiliFilePaths.dirname(savePath));
    if (!directory.existsSync()) return 0;
    final prefix = BiliFilePaths.basename(savePath);
    var removed = 0;
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = BiliFilePaths.basename(entity.path);
      if (!name.startsWith(prefix)) continue;
      if (name == prefix) continue;
      final suffix = name.substring(prefix.length);
      if (!RegExp(r'^temp\d+(_pre)?$').hasMatch(suffix)) continue;
      entity.deleteSync();
      removed += 1;
    }
    return removed;
  }

  /// `bytes 0-101/12345` -> `12345`; `null` when absent or `*`.
  static int? _totalFromContentRange(String? contentRange) {
    if (contentRange == null || contentRange.isEmpty) return null;
    final slash = contentRange.lastIndexOf('/');
    if (slash < 0) return null;
    final total = contentRange.substring(slash + 1).trim();
    if (total == '*') return null;
    final parsed = int.tryParse(total);
    return (parsed != null && parsed > 0) ? parsed : null;
  }

  static int _lengthOf(String path) {
    final file = File(path);
    return file.existsSync() ? file.lengthSync() : 0;
  }

  static void _throwIfCancelled(CancelToken? cancelToken) {
    if (cancelToken != null && cancelToken.isCancelled) {
      throw const BiliDownloadCancelledException();
    }
  }
}
