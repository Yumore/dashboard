import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data.dart';

/// The three states every screen section can be in.
///
/// Pages mutate this from `initState` / user callbacks only, never from
/// `build`, so no request can start during a frame.
class FlutterDouBanLoadState<T> {
  FlutterDouBanData<T>? data;
  Object? error;
  bool loading = false;

  bool get hasData => data != null;
  bool get hasError => error != null;

  /// Drops everything so the next `load` is allowed to run again.
  void reset() {
    data = null;
    error = null;
    loading = false;
  }
}
