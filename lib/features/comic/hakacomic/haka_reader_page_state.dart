import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/comic/hakacomic/haka_image_base.dart';
import 'package:dashboard/features/comic/hakacomic/haka_reader_controller.dart';
import 'package:dashboard/features/comic/hakacomic/haka_reader_page.dart';
import 'package:dashboard/features/comic/hakacomic/haka_state_view.dart';

/// State of [HakaReaderPage].
class HakaReaderPageState extends State<HakaReaderPage> {
  late final HakaReaderController _controller;
  final PageController _pageController = PageController();
  final FocusNode _focusNode = FocusNode();
  bool _vertical = true;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _controller = HakaReaderController(
      repository: widget.repository,
      comicId: widget.comicId,
      chapters: widget.chapters,
      readRecords: widget.readRecords,
      initialOrder: widget.initialOrder,
    );
    _load();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load(resumePage: widget.initialPage);
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToCurrent());
  }

  void _jumpToCurrent() {
    if (!mounted || !_pageController.hasClients) return;
    final target = _controller.currentIndex;
    if (_pageController.page?.round() == target) return;
    _pageController.jumpToPage(target);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.space) {
      _controller.turnPage(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      _controller.turnPage(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _changeChapter(Future<void> Function() action) async {
    await action();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToCurrent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: HakaStateView<List<HakaImageBase>>(
                    state: _controller.state,
                    onRetry: _controller.retry,
                    builder: (context, images) => GestureDetector(
                      onTap: () =>
                          setState(() => _showOverlay = !_showOverlay),
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: _vertical
                            ? Axis.vertical
                            : Axis.horizontal,
                        onPageChanged: _controller.onPageChanged,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return InteractiveViewer(
                            maxScale: 3,
                            child: CachedNetworkImage(
                              imageUrl: image.url,
                              cacheKey: image.cacheKey,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: Colors.white54,
                                    ),
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (_showOverlay) _buildOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    final chapter = _controller.chapter;
    return Column(
      children: [
        SafeArea(
          child: Row(
            children: [
              IconButton(
                color: Colors.white,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  chapter?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                color: Colors.white,
                tooltip: _vertical ? '切换横向阅读' : '切换纵向阅读',
                onPressed: () => setState(() => _vertical = !_vertical),
                icon: Icon(
                  _vertical ? Icons.swap_horiz : Icons.swap_vert,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _controller.hasPreviousChapter
                    ? () => _changeChapter(_controller.previousChapter)
                    : null,
                child: const Text(
                  '上一话',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                '${_controller.displayPage}/${_controller.totalPages}'
                ' · ${(_controller.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: _controller.hasNextChapter
                    ? () => _changeChapter(_controller.nextChapter)
                    : null,
                child: const Text(
                  '下一话',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
