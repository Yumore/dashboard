import 'dart:async';

import 'package:dashboard/features/movie/youtubedl/youtubedl_download_cancelled_exception.dart';

/// Minimal cancellation primitive used by the queue and the stream sink.
class YoutubeDlCancellationToken {
  final Completer<void> _completer = Completer<void>();
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _completer.complete();
  }

  void throwIfCancelled() {
    if (_cancelled) throw const YoutubeDlDownloadCancelledException();
  }
}
