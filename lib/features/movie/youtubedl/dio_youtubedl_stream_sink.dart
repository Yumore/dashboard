import 'dart:async';
import 'dart:io';

import 'package:dashboard/features/movie/youtubedl/youtubedl_cancellation_token.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_download_cancelled_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_exception.dart';
import 'package:dashboard/features/movie/youtubedl/youtubedl_stream_sink.dart';
import 'package:dio/dio.dart';

/// Default sink: streams bytes straight to disk with `dio.download`.
class DioYouTubeDlStreamSink implements YoutubeDlStreamSink {
  DioYouTubeDlStreamSink({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: Duration.zero,
              validateStatus: (_) => true,
              headers: const <String, String>{
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                    'AppleWebKit/537.36 (KHTML, like Gecko) '
                    'Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          );

  final Dio _dio;

  @override
  Future<void> write({
    required Uri url,
    required String path,
    required int totalBytes,
    required YoutubeDlCancellationToken cancellation,
    required void Function(int received) onProgress,
  }) async {
    final cancelToken = CancelToken();
    unawaited(
      cancellation.whenCancelled.then((_) {
        if (!cancelToken.isCancelled) cancelToken.cancel('cancelled');
      }),
    );
    try {
      final response = await _dio.download(
        url.toString(),
        path,
        cancelToken: cancelToken,
        deleteOnError: true,
        options: Options(receiveTimeout: Duration.zero),
        onReceiveProgress: (received, total) {
          if (cancellation.isCancelled) {
            if (!cancelToken.isCancelled) cancelToken.cancel('cancelled');
            return;
          }
          onProgress(received);
        },
      );
      if (cancellation.isCancelled) {
        throw const YoutubeDlDownloadCancelledException();
      }
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        await delete(path);
        throw YoutubeDlStreamException('下载失败：HTTP $status');
      }
    } on DioException catch (error) {
      if (cancellation.isCancelled || CancelToken.isCancel(error)) {
        throw const YoutubeDlDownloadCancelledException();
      }
      throw YoutubeDlStreamException(
        '下载失败：${error.message ?? error.type.name}',
      );
    }
  }

  @override
  Future<bool> exists(String path) => File(path).exists();

  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
