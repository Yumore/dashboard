import 'package:cached_network_image/cached_network_image.dart';
import 'package:dashboard/features/comic/u17_chapter.dart';
import 'package:dashboard/features/comic/u17_reader_page.dart';
import 'package:flutter/material.dart';

class U17ReaderPageState extends State<U17ReaderPage> {
  final _scroll = ScrollController();
  late U17Chapter _chapter;
  late U17Chapter _requested;
  List<Uri> _images = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _chapter = widget.initialChapter;
    _requested = _chapter;
    _load(_chapter);
  }

  Future<void> _load(U17Chapter chapter) async {
    if (_loading || chapter.locked) return;
    setState(() {
      _loading = true;
      _error = null;
      _requested = chapter;
    });
    try {
      final images = await widget.source.images(chapter.id);
      if (!mounted) return;
      if (images.isEmpty) throw const FormatException('本章节没有可显示图片');
      await widget.store.remember(widget.comic, chapter);
      if (!mounted) return;
      setState(() {
        _chapter = chapter;
        _images = images;
      });
      if (_scroll.hasClients) _scroll.jumpTo(0);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  U17Chapter? _adjacent(int delta) {
    final index = widget.chapters.indexWhere(
      (chapter) => chapter.id == _chapter.id,
    );
    final target = index + delta;
    if (index < 0 || target < 0 || target >= widget.chapters.length) {
      return null;
    }
    final chapter = widget.chapters[target];
    return chapter.locked ? null : chapter;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previous = _adjacent(-1);
    final next = _adjacent(1);
    return Scaffold(
      appBar: AppBar(title: Text(_chapter.name)),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            ListTile(
              title: Text('章节加载失败：$_error'),
              trailing: TextButton(
                onPressed: _loading ? null : () => _load(_requested),
                child: const Text('重试'),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              itemCount:
                  _images.length + (next == null || _images.isEmpty ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return TextButton(
                    onPressed: _loading ? null : () => _load(next!),
                    child: const Text('继续阅读下一章'),
                  );
                }
                return Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: _images[index].toString(),
                      fit: BoxFit.fitWidth,
                      placeholder: (_, _) => const SizedBox(
                        height: 160,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, _, _) =>
                          ListTile(title: Text('第 ${index + 1} 页加载失败')),
                    ),
                    Text(
                      '第 ${index + 1} 页',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: previous == null || _loading
                      ? null
                      : () => _load(previous),
                  child: const Text('上一章'),
                ),
                TextButton(
                  onPressed: next == null || _loading
                      ? null
                      : () => _load(next),
                  child: const Text('下一章'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
