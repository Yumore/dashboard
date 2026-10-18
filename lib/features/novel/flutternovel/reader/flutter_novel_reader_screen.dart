import 'package:dashboard/features/novel/flutternovel/reader/content_state.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_page_turn_engine.dart';
import 'package:dashboard/features/novel/flutternovel/reader/novel_reader_controller.dart';
import 'package:dashboard/features/novel/flutternovel/reader/reader_animation_type.dart';
import 'package:flutter/material.dart';

/// The full-screen reader.
///
/// Painting is a [CustomPaint] rather than a widget per paragraph: the source
/// reader rendered every page onto a `ui.Canvas`, and the page-turn animations
/// need the *same* content twice (current page and the page behind it) inside
/// one transform. Two painters — the text mapper below and the page painter —
/// keep that explicit.
class FlutterNovelReaderScreen extends StatefulWidget {
  const FlutterNovelReaderScreen({super.key, required this.controller});

  final NovelReaderController controller;

  @override
  State<FlutterNovelReaderScreen> createState() =>
      _FlutterNovelReaderScreenState();
}

class _FlutterNovelReaderScreenState extends State<FlutterNovelReaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  bool _menuVisible = false;

  NovelReaderController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _animation
      ..addListener(_onAnimationValue)
      ..addStatusListener(_onAnimationStatus);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _animation
      ..removeListener(_onAnimationValue)
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onAnimationValue() => _controller.onAnimationTick(_animation.value);

  void _onAnimationStatus(AnimationStatus status) {
    final state = _controller.turnState;
    if (state == NovelPageTurnState.confirming &&
        status == AnimationStatus.completed) {
      _controller.onAnimationCompleted();
    } else if (state == NovelPageTurnState.cancelling &&
        status == AnimationStatus.dismissed) {
      _controller.onAnimationCompleted();
    }
  }

  void _endGesture({required bool cancelled, double velocity = 0}) {
    _controller.onTouchEnd(velocity: velocity, cancelled: cancelled);
    final target = _controller.engine.targetAnimationValue;
    if (target == null) return;
    if (target >= 1) {
      _animation.forward(from: _animation.value);
      return;
    }
    if (_animation.value == 0) _animation.value = 1;
    _animation.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _controller.config;
    return Scaffold(
      backgroundColor: config.currentCanvasBgColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (details) =>
            _controller.onTouchBegin(details.localPosition),
        onVerticalDragUpdate: (details) =>
            _controller.onTouchUpdate(details.localPosition),
        onVerticalDragEnd: (details) => _endGesture(
          cancelled: false,
          velocity: details.primaryVelocity ?? 0,
        ),
        onVerticalDragCancel: () => _endGesture(cancelled: true),
        onTap: () => setState(() => _menuVisible = !_menuVisible),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _controller.setViewport(size);
                  });
                  return CustomPaint(
                    painter: _ReaderPagePainter(controller: _controller),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
            if (_controller.loading)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_controller.contentState != ContentState.normal)
              Positioned.fill(child: _errorOverlay(context)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _menuVisible ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !_menuVisible,
                  child: _bottomBar(context),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: AnimatedOpacity(
                opacity: _menuVisible ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !_menuVisible,
                  child: _topBar(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorOverlay(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _controller.contentState == ContentState.notFound
                ? '本章没有内容'
                : (_controller.error ?? '加载失败'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => _controller.loadChapter(_controller.chapterIndex),
            child: const Text('重试'),
          ),
        ],
      ),
    ),
  );

  Widget _topBar(BuildContext context) => Material(
    color: Colors.black54,
    child: SafeArea(
      bottom: false,
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              _controller.currentChapterTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _bottomBar(BuildContext context) => Material(
    color: Colors.black54,
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Slider(
            value: _controller.progressRatio,
            onChanged: _controller.pageCount == 0
                ? null
                : (value) {
                    final page = (value * _controller.pageCount)
                        .floor()
                        .clamp(0, _controller.pageCount - 1);
                    _controller.jumpToPage(page);
                  },
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: <Widget>[
              for (final type in ReaderAnimationType.all)
                ChoiceChip(
                  label: Text(ReaderAnimationType.label(type)),
                  selected: _controller.config.currentAnimationMode == type,
                  onSelected: (_) => setState(
                    () => _controller.setAnimationType(type),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_controller.chapterIndex + 1}/${_controller.chapters.length} 章'
            '  ·  ${_controller.pageIndex + 1}/${_controller.pageCount} 页',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Paints the current page plus whichever neighbour the active animation needs.
class _ReaderPagePainter extends CustomPainter {
  _ReaderPagePainter({required this.controller});

  final NovelReaderController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final config = controller.config;
    final padding = config.contentPadding.toDouble();
    canvas.drawRect(Offset.zero & size, controller.bgPaint);

    final previous = controller.preParagraphs;
    final current = controller.currentParagraphs;
    final next = controller.nextParagraphs;

    void drawPage(List<String> paragraphs, Offset origin) {
      if (paragraphs.isEmpty) return;
      final painter = TextPainter(textDirection: TextDirection.ltr);
      var dy = origin.dy;
      for (final paragraph in paragraphs) {
        painter.text = TextSpan(
          text: paragraph,
          style: TextStyle(
            fontSize: config.fontSize.toDouble(),
            height: config.lineHeight / config.fontSize,
            color: Colors.black,
          ),
        );
        painter.layout(maxWidth: size.width - padding * 2);
        painter.paint(canvas, Offset(origin.dx + padding, dy));
        dy += config.lineHeight.toDouble() + config.paragraphSpacing;
        if (dy > size.height + config.lineHeight) break;
      }
    }

    void drawTitle(String? text) {
      if (text == null || text.isEmpty) return;
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: config.titleFontSize.toDouble(),
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width - padding * 2);
      painter.paint(canvas, Offset(padding, padding));
    }

    void drawPageCounter() {
      final painter = TextPainter(
        text: TextSpan(
          text: '${controller.pageIndex + 1} / ${controller.pageCount}',
          style: TextStyle(
            fontSize: config.bottomTipFontSize.toDouble(),
            color: Colors.black45,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          (size.width - painter.width) / 2,
          size.height - painter.height - padding,
        ),
      );
    }

    final snapshot = controller.engine.snapshot();
    switch (snapshot.type) {
      case ReaderAnimationType.slideTurn:
        /// The whole page strip moves vertically under the finger.
        final shift = snapshot.offset;
        drawPage(previous, Offset(0, shift - size.height));
        drawPage(current, Offset(0, shift));
        drawPage(next, Offset(0, shift + size.height));
      case ReaderAnimationType.coverTurn:
        /// The incoming page sits still and the leaving page slides off it.
        drawPage(snapshot.turnNext ? next : previous, Offset.zero);
        final covered = snapshot.offset;
        drawPage(current, Offset(0, covered));
        final edge = covered + size.height / 2;
        if (edge > 0 && edge < size.height) {
          canvas.drawRect(
            Rect.fromLTWH(0, edge - 6, size.width, 6),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.black26, Colors.transparent],
              ).createShader(Rect.fromLTWH(0, edge - 6, size.width, 6)),
          );
        }
      default:
        /// Simulation: the page peels from the side the finger grabbed.
        drawPage(snapshot.turnNext ? next : previous, Offset.zero);
        final fold = snapshot.offset.abs().clamp(0.0, size.width);
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(0, 0, size.width - fold, size.height));
        drawPage(current, Offset.zero);
        canvas.restore();
        if (fold > 0 && fold < size.width) {
          canvas.drawRect(
            Rect.fromLTWH(size.width - fold - 8, 0, 8, size.height),
            Paint()
              ..shader = const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Colors.transparent, Colors.black26],
              ).createShader(
                Rect.fromLTWH(size.width - fold - 8, 0, 8, size.height),
              ),
          );
        }
    }

    drawTitle(controller.currentChapterTitle);
    drawPageCounter();
  }

  @override
  bool shouldRepaint(covariant _ReaderPagePainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.controller.pageIndex != controller.pageIndex ||
      oldDelegate.controller.engine.state != controller.engine.state ||
      oldDelegate.controller.engine.progress != controller.engine.progress ||
      oldDelegate.controller.engine.offset != controller.engine.offset;
}
