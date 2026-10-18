import 'dart:ui';

import 'package:dashboard/features/novel/flutternovel/reader/animation_type.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_host.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_type.dart';

/// Where a page-turn gesture currently is.
enum NovelPageTurnState {
  /// Nothing is being dragged and no animation is running.
  idle,

  /// A pointer is down and the gesture is still deciding its direction.
  dragging,

  /// The gesture is committed; the turn animation runs to completion.
  confirming,

  /// The gesture did not pass the threshold; the animation rewinds.
  cancelling,
}

/// A snapshot of the page-turn engine, for painting and for assertions.
class NovelPageTurnSnapshot {
  const NovelPageTurnSnapshot({
    required this.type,
    required this.state,
    required this.turnNext,
    required this.offset,
    required this.progress,
  });

  /// One of [ReaderAnimationType.simulationTurn] / [coverTurn] / [slideTurn].
  final int type;

  final NovelPageTurnState state;

  /// Whether this turn moves forward (towards the next page).
  final bool turnNext;

  /// Signed drag distance: negative forward (the finger moved up), positive
  /// backward. Only the slide type keeps a non-zero offset while settling.
  final double offset;

  /// 0→1 progress of the running confirm/cancel animation.
  final double progress;

  bool get isAnimating =>
      state == NovelPageTurnState.confirming ||
      state == NovelPageTurnState.cancelling;

  @override
  String toString() =>
      'NovelPageTurnSnapshot(type: $type, state: $state, turnNext: $turnNext, '
      'offset: $offset, progress: $progress)';
}

/// The page-turn decision layer for the reader (the port of the source's
/// `AnimationPageBase` subclasses in
/// `lib/app/novel/widget/reader/content/helper/animation/`).
///
/// The source mixed the gesture state machine into canvases that called
/// `AnimationController.animateTo` directly, which made it untestable without a
/// ticking widget. This port keeps exactly the source's decision rules —
/// thresholds, direction, confirm/cancel areas — in a plain Dart object and
/// exposes the animation value as [progress]; the painter drives [progress] from
/// the widget's own controller. That makes every transition assertable with a
/// fake host, with no pump and no platform views.
///
/// Interaction with the host follows the source exactly:
///  * cover / simulation: the page is turned **once, when [animationCompleted]
///    fires** after the confirm animation finished;
///  * slide: pages are turned **when the drag settles**, after the cumulative
///    offset has crossed whole page heights (the source's `currentIndex`).
class NovelPageTurnEngine {
  NovelPageTurnEngine({
    required this.host,
    this.type = ReaderAnimationType.simulationTurn,
  });

  /// The reader state the animations read and drive.
  final ReaderAnimationHost host;

  /// [ReaderAnimationType.simulationTurn] (1), [coverTurn] (2) or
  /// [slideTurn] (3).
  int type;

  /// The cover animation's orientation. The host reader is portrait-only, so
  /// this stays the source's `ORIENTATION_VERTICAL`.
  static const int orientationVertical = 1;
  static const int orientationHorizontal = 0;

  /// Screen-space size of the reader viewport.
  Size size = Size.zero;

  /// Last pointer position.
  Offset touch = Offset.zero;

  Offset _startTouch = Offset.zero;
  double _offset = 0;
  double _progress = 0;
  bool _turnNext = true;
  bool _touchActive = false;
  NovelPageTurnState _state = NovelPageTurnState.idle;

  NovelPageTurnState get state => _state;

  bool get isAnimating => snapshot().isAnimating;

  /// Signed drag distance in logical pixels.
  double get offset => _offset;

  /// 0→1 animation value.
  double get progress => _progress;

  /// Whether the committed turn moves forward.
  bool get turnNext => _turnNext;

  static const double _flingVelocityThreshold = 50;

  /// The slide offset (logical pixels) implied by whole pages of [pageHeight]
  /// having been turned. Pure, so the arithmetic is testable on its own.
  static double slideOffsetFor(int limit, int pageHeight, double dragDistance) {
    if (pageHeight <= 0) return 0;
    final moved =
        (limit * pageHeight).toDouble() + (dragDistance % pageHeight);
    return moved == 0 ? 0 : -moved;
  }

  NovelPageTurnSnapshot snapshot() => NovelPageTurnSnapshot(
    type: type,
    state: _state,
    turnNext: _turnNext,
    offset: _offset,
    progress: _progress,
  );

  void setViewportSize(Size value) {
    if (value == size) return;
    size = value;
    _reset();
  }

  /// Changes the page-turn animation while the reader is idle.
  bool setType(int value) {
    if (!ReaderAnimationType.all.contains(value) || value == type) {
      return false;
    }
    if (_state != NovelPageTurnState.idle) return false;
    type = value;
    _reset();
    return true;
  }

  /// A pointer went down.
  void begin(Offset position) {
    if (_state == NovelPageTurnState.confirming) return;
    _reset();
    touch = position;
    _startTouch = position;
    _touchActive = true;
    _state = NovelPageTurnState.dragging;
  }

  /// A pointer moved.
  void update(Offset position) {
    if (!_touchActive) return;
    final previous = touch;
    touch = position;

    switch (type) {
      case ReaderAnimationType.slideTurn:
        /// The source's slide animation moved the whole page content under the
        /// finger (content moves up as the finger moves up).
        _offset += position.dy - previous.dy;
        _state = NovelPageTurnState.dragging;
      case ReaderAnimationType.coverTurn:
        /// Cover: the drag direction decides the turn, and the offset follows
        /// the finger vertically (the source's `ORIENTATION_VERTICAL`).
        _turnNext = (position.dy - _startTouch.dy) < 0;
        _offset = position.dy - _startTouch.dy;
        _state = NovelPageTurnState.dragging;
      default:
        /// Simulation: the source anchored on the touched corner, so a touch on
        /// the right half turns forward and the left half turns backward.
        _turnNext = _startTouch.dx >= size.width / 2;
        _offset = position.dx - _startTouch.dx;
        _state = NovelPageTurnState.dragging;
    }
  }

  /// The source's `isConfirmArea()` / `isCancelArea()` split: past the
  /// threshold the gesture confirms, otherwise it rewinds.
  double get confirmThreshold => switch (type) {
    ReaderAnimationType.coverTurn => size.height / 4,
    ReaderAnimationType.slideTurn => size.height / 2,
    _ => size.width * 3 / 4,
  };

  bool isConfirmArea() => _offset.abs() > confirmThreshold;

  bool isCancelArea() => !isConfirmArea();

  /// A pointer went up (or was cancelled): decides confirm vs cancel, and for
  /// the slide type resolves the drag/fling into whole page turns.
  void end({double velocity = 0, bool cancelled = false}) {
    if (!_touchActive) return;
    _touchActive = false;

    if (type == ReaderAnimationType.slideTurn) {
      _settleSlide(velocity, cancelled: cancelled);
      return;
    }

    final canTurn = _turnNext ? host.isCanGoNext() : host.isCanGoPre();
    final commit = !cancelled && canTurn && isConfirmArea();

    /// A committing drag animates 0→1; a cancelled one rewinds 1→0.
    _state = commit
        ? NovelPageTurnState.confirming
        : NovelPageTurnState.cancelling;
    _progress = commit ? 0 : 1;
    _offset = 0;
  }

  /// The running confirm/cancel animation moved. At 1.0 a confirming turn is
  /// applied by [animationCompleted].
  void animationValue(double value) {
    if (!isAnimating) return;
    _progress = value.clamp(0.0, 1.0);
    if (_state == NovelPageTurnState.confirming) {
      _offset = -confirmThreshold * _progress;
    } else if (_state == NovelPageTurnState.cancelling) {
      _offset = -confirmThreshold * (1 - _progress);
    }
  }

  /// The controller reported completion; only a confirming turn advances a
  /// page. Returns true when a page was actually turned.
  bool animationCompleted() {
    if (_state == NovelPageTurnState.confirming) {
      final turned = _turnNext ? host.isCanGoNext() : host.isCanGoPre();
      if (turned) {
        if (_turnNext) {
          host.nextPage();
        } else {
          host.prePage();
        }
      }
      _reset();
      return turned;
    }
    if (_state == NovelPageTurnState.cancelling) {
      _reset();
    }
    return false;
  }

  /// The value the host's animation controller should run to, or null when no
  /// animation is needed.
  double? get targetAnimationValue => switch (_state) {
    NovelPageTurnState.confirming => 1,
    NovelPageTurnState.cancelling => 0,
    _ => null,
  };

  /// Resolves a finished slide drag into whole page turns.
  void _settleSlide(double velocity, {required bool cancelled}) {
    final pageHeight = size.height;
    if (pageHeight <= 0) {
      _reset();
      return;
    }

    final fast = !cancelled && velocity.abs() > _flingVelocityThreshold;
    final forward = fast ? velocity < 0 : _offset < 0;

    /// Whole pages the drag has already crossed, plus a page the fling projects
    /// past the boundary it was heading for.
    var turns = (_offset.abs() / pageHeight).floor();
    if (fast) {
      final projected = _offset + velocity * 0.3;
      final projectedTurns = (projected.abs() / pageHeight).floor();
      if (projectedTurns > turns) turns = projectedTurns;
    }

    final canTurn = cancelled
        ? false
        : forward
        ? host.isCanGoNext()
        : host.isCanGoPre();

    if (canTurn) {
      for (var index = 0; index < turns; index++) {
        if (forward) {
          if (!host.isCanGoNext()) break;
          host.nextPage();
        } else {
          if (!host.isCanGoPre()) break;
          host.prePage();
        }
      }
    }

    _reset();
  }

  /// The source's `ANIMATION_TYPE` enum, exposed for the painter.
  static const AnimationType typeConfirm = AnimationType.confirm;
  static const AnimationType typeCancel = AnimationType.cancel;
  static const AnimationType typeFiling = AnimationType.fling;

  void _reset() {
    _offset = 0;
    _progress = 0;
    _touchActive = false;
    _state = NovelPageTurnState.idle;
  }
}
