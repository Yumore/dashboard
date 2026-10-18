import 'dart:async';

/// Cancellable one-shot timer, abstracted so tests can fire it manually.
abstract class MyTvTimer {
  void cancel();
}

/// Creates a [MyTvTimer] for a delay and callback.
typedef MyTvTimerFactory =
    MyTvTimer Function(Duration duration, void Function() callback);

/// Default factory backed by a real [Timer].
MyTvTimer defaultMyTvTimerFactory(
  Duration duration,
  void Function() callback,
) => _SystemMyTvTimer(duration, callback);

class _SystemMyTvTimer implements MyTvTimer {
  _SystemMyTvTimer(Duration duration, void Function() callback)
    : _timer = Timer(duration, callback);

  final Timer _timer;

  @override
  void cancel() => _timer.cancel();
}
