import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/comic/picacomic/controllers/picacomic_reader_controller.dart';
import 'package:dashboard/features/comic/picacomic/pages/picacomic_reader_page.dart';
import 'package:flutter/material.dart';

class PicacomicReaderPageState extends State<PicacomicReaderPage> {
  late final PicacomicReaderController _controller;
  late final bool _ownsController;
  late final PageController _pageController;
  bool _showOverlay = true;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        PicacomicReaderController(
          sourceKey: widget.sourceKey,
          comicId: widget.comicId,
          chapterId: widget.chapterId,
          chapterName: widget.chapterName,
          title: widget.title,
          cover: widget.cover,
          chapterCount: widget.chapterCount,
        );
    _pageController = PageController();
    _controller.load().then((_) {
      if (!mounted) return;
      _initialPage = _controller.page;
      if (_initialPage > 0 && _pageController.hasClients) {
        _pageController.jumpToPage(_initialPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loading && _controller.pageCount == 0) {
            return const Center(child: CircularProgressIndicator());
          }
          final error = _controller.error;
          if (error != null && _controller.pageCount == 0) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _controller.load(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          if (_controller.pageCount == 0) {
            return const Center(
              child: Text('没有图片', style: TextStyle(color: Colors.white)),
            );
          }
          return Stack(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showOverlay = !_showOverlay),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _controller.pageCount,
                  onPageChanged: _controller.goTo,
                  itemBuilder: (context, index) {
                    final url = _controller.images[index];
                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          httpHeaders: _controller.headers,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_showOverlay) _topBar(),
              if (_showOverlay) _bottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                _controller.currentChapterName ?? _controller.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${_controller.page + 1} / ${_controller.pageCount}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
