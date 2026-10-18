import 'package:dashboard/features/anime/animetrace/animetrace_ping_status.dart';
import 'package:dio/dio.dart';

/// Reachability probe for source sites.
///
/// The source app used `dart_ping` (ICMP, unavailable in the host dependency
/// set) and fell back to a `dio` HEAD request measured with a stopwatch. The
/// port keeps only that measurable fallback: it is injectable so tests can hand
/// in a `Dio` with a fake `HttpClientAdapter`, and the timeout is injectable so
/// the probe cannot stall a page.
class AnimeTraceHealthProbe {
  AnimeTraceHealthProbe({
    Dio? dio,
    this.timeout = const Duration(seconds: 5),
    this.attempts = 3,
  }) : dio = dio ?? Dio();

  final Dio dio;
  final Duration timeout;

  /// How many times a probe may retry before reporting a timeout. The source
  /// app accepted a host as connectable when at least one of three pings
  /// answered.
  final int attempts;

  /// Probes [url] and reports a terminal (non-`pinging`) status.
  Future<AnimeTracePingStatus> check(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return const AnimeTracePingStatus(needPing: false);
    }
    for (var attempt = 0; attempt < attempts; attempt++) {
      final stopwatch = Stopwatch()..start();
      final ok = await _head(trimmed);
      stopwatch.stop();
      if (ok) {
        return AnimeTracePingStatus(
          needPing: false,
          connectable: true,
          time: stopwatch.elapsedMilliseconds,
        );
      }
    }
    return const AnimeTracePingStatus(needPing: false, time: -1);
  }

  /// Single HEAD request used by the "fix lapse covers" flow: an anime cover is
  /// considered lapsed when its URL no longer answers with HTTP 200.
  Future<bool> isReachable(String url, {Duration? timeout}) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    return _head(trimmed, timeout: timeout);
  }

  Future<bool> _head(String url, {Duration? timeout}) async {
    try {
      final response = await dio.head<void>(
        url,
        options: Options(
          followRedirects: true,
          receiveTimeout: timeout ?? this.timeout,
          sendTimeout: timeout ?? this.timeout,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
