import 'dart:ui';

import 'package:dashboard/features/novel/flutternovel/reader/reader_screen_metrics.dart';

/// One pointer event delivered to a page-turn animation.
///
/// Ported from the source's `TouchEvent` (manager_reader_page.dart). The
/// [touchDetail] slot carries the `DragEndDetails` that the slide animation
/// feeds to its fling simulation; it is typed `Object?` so the single event type
/// can travel through the manager and painter without generic variance noise.
class ReaderTouchEvent {
  ReaderTouchEvent(this.action, this.touchPos);

  static const int actionDown = 0;
  static const int actionMove = 1;
  static const int actionUp = 2;
  static const int actionCancel = 3;

  final int action;
  final Offset touchPos;
  Object? touchDetail;

  /// The source defaulted the position to the full screen size, i.e. the
  /// bottom-right corner of the viewport.
  factory ReaderTouchEvent.fullScreen(int action) => ReaderTouchEvent(
    action,
    Offset(ReaderScreenMetrics.width, ReaderScreenMetrics.height),
  );

  @override
  bool operator ==(Object other) =>
      other is ReaderTouchEvent &&
      action == other.action &&
      touchPos == other.touchPos;

  @override
  int get hashCode => Object.hash(action, touchPos);
}
