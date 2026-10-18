import 'package:dashboard/features/reading/eso/eso_api.dart';
import 'package:dashboard/features/reading/eso/eso_api_manager.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_item.dart';
import 'package:dashboard/features/reading/eso/eso_chapter_page_provider.dart';
import 'package:dashboard/features/reading/eso/eso_content_provider.dart';
import 'package:dashboard/features/reading/eso/eso_history_item_store.dart';
import 'package:dashboard/features/reading/eso/eso_playback_launcher.dart';
import 'package:dashboard/features/reading/eso/eso_reader_config.dart';
import 'package:dashboard/features/reading/eso/eso_reader_page.dart';
import 'package:dashboard/features/reading/eso/eso_rss_page.dart';
import 'package:dashboard/features/reading/eso/eso_search_item.dart';
import 'package:flutter/material.dart';

/// eso 阅读页状态：目录分页、正文加载、章内导航与外观设置。
///
/// 源实现的翻页由 `text_composition` 包完成（宿主没有该依赖），这里用
/// 「纵向滚动 + 章节切换」的阅读模式；eso 默认的 `novelPageSwitch` 本身就是
/// 滚动模式（`novelScroll = 0`），因此默认体验与源实现一致。
class EsoReaderPageState extends State<EsoReaderPage> {
  final EsoHistoryItemStore _historyStore = EsoHistoryItemStore();
  final EsoReaderConfig _config = EsoReaderConfig();
  late final EsoChapterPageProvider _chapterProvider;

  EsoContentProvider? _contentProvider;
  List<String> _paragraphs = <String>[];
  bool _loading = true;
  String? _error;

  EsoSearchItem get _item => widget.item;

  List<EsoChapterItem> get _chapters => _item.chapters ?? <EsoChapterItem>[];

  @override
  void initState() {
    super.initState();
    _chapterProvider = EsoChapterPageProvider(
      searchItem: _item,
      historyStore: _historyStore,
    );
    _boot();
  }

  @override
  void dispose() {
    _chapterProvider.dispose();
    _contentProvider?.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await _config.load();
    if (!mounted) return;
    try {
      await _chapterProvider.ready;
      if (!mounted) return;
      if (_item.ruleContentType == EsoApi.audio) {
        setState(() => _loading = false);
        await _playAudio();
        return;
      }
      if (_item.ruleContentType == EsoApi.rss) {
        setState(() => _loading = false);
        return;
      }
      await _loadContent(_item.durChapterIndex ?? 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadContent(int index, {bool prefetch = false}) async {
    if (index < 0 || index >= _chapters.length) {
      setState(() {
        _paragraphs = <String>[];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = _contentProvider ??
        EsoContentProvider(_item, historyStore: _historyStore);
    _contentProvider = provider;
    await provider.ready;
    final content = await provider.loadChapter(index, true, prefetch);
    if (!mounted) return;
    setState(() {
      _paragraphs = content;
      _loading = false;
    });
    await _historyStore.insertOrUpdateHistoryItem(_item);
  }

  Future<void> _playAudio() async {
    final chapters = _chapters;
    if (chapters.isEmpty) {
      setState(() => _error = '这个源没有返回音频地址');
      return;
    }
    final index = _item.durChapterIndex ?? 0;
    final chapter = chapters[index.clamp(0, chapters.length - 1)];
    final content = await EsoApiManager.instance
        .getContent(_item.originTag, chapter.url ?? '');
    if (!mounted) return;
    await EsoPlaybackLauncher.openAudio(
      context,
      title: '${_item.name ?? ''} ${chapter.name ?? ''}',
      content: content,
    );
  }

  Future<void> _openChapter(int index) async {
    if (index < 0 || index >= _chapters.length) return;
    await _chapterProvider.changeChapter(index);
    await _loadContent(index);
  }

  Future<void> _toggleFavorite() async {
    await _historyStore.insertOrUpdateHistoryItem(_item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入书架')),
    );
  }

  void _showInfo() {
    final info = _contentProvider?.info ?? '';
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('解析信息'),
        content: SingleChildScrollView(
          child: Text(info.isEmpty ? '暂无信息' : info),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showChapters() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView.builder(
          itemCount: _chapters.length,
          itemBuilder: (context, index) {
            final chapter = _chapters[index];
            final selected = index == (_item.durChapterIndex ?? 0);
            return ListTile(
              dense: true,
              selected: selected,
              title: Text(chapter.name ?? ''),
              subtitle: (chapter.time ?? '').isEmpty
                  ? null
                  : Text(chapter.time ?? ''),
              trailing: (chapter.cover ?? '').isEmpty
                  ? null
                  : const Icon(Icons.image_outlined, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                _openChapter(index);
              },
            );
          },
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          void apply(void Function() change) {
            setSheetState(change);
            setState(() {});
            _config.save();
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('字号 ${_config.fontSize.toStringAsFixed(0)}'),
                  Slider(
                    value: _config.fontSize,
                    min: 10,
                    max: 40,
                    divisions: 30,
                    onChanged: (v) => apply(() => _config.setFontSize(v)),
                  ),
                  Text('行高 ${_config.lineHeight.toStringAsFixed(1)}'),
                  Slider(
                    value: _config.lineHeight,
                    min: 1,
                    max: 3,
                    divisions: 20,
                    onChanged: (v) => apply(() => _config.setLineHeight(v)),
                  ),
                  Text('段距 ${_config.paragraphPadding.toStringAsFixed(0)}'),
                  Slider(
                    value: _config.paragraphPadding,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    onChanged: (v) =>
                        apply(() => _config.setParagraphPadding(v)),
                  ),
                  Text('缩进 ${_config.indentation}'),
                  Slider(
                    value: _config.indentation.toDouble(),
                    min: 0,
                    max: 4,
                    divisions: 4,
                    onChanged: (v) =>
                        apply(() => _config.setIndentation(v.round())),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: <Widget>[
                      for (final color in const <int>[
                        0xFFF5DEB3,
                        0xFFFFFFFF,
                        0xFFC7EDCC,
                        0xFF1B1B1B,
                      ])
                        ChoiceChip(
                          label: const Text('底色'),
                          selected: _config.backgroundColor == color,
                          backgroundColor: Color(color),
                          onSelected: (_) => apply(
                            () => _config.backgroundColor = color,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_item.ruleContentType == EsoApi.rss) {
      return EsoRssPage(item: _item);
    }
    return Scaffold(
      backgroundColor: Color(_config.backgroundColor),
      appBar: AppBar(
        title: Text(
          _item.name ?? '',
          style: const TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          if (_item.ruleContentType == EsoApi.audio)
            IconButton(
              onPressed: _playAudio,
              icon: const Icon(Icons.play_arrow),
              tooltip: '播放',
            ),
          IconButton(
            onPressed: _toggleFavorite,
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: '加入书架',
          ),
          IconButton(
            onPressed: _showChapters,
            icon: const Icon(Icons.list),
            tooltip: '目录',
          ),
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: '解析信息',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: '阅读设置',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = _error;
    if (error != null && _paragraphs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('解析失败：$error', textAlign: TextAlign.center),
        ),
      );
    }
    if (_paragraphs.isEmpty) {
      return const Center(child: Text('没有正文'));
    }
    final indent = '　' * _config.indentation;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _paragraphs.length,
      itemBuilder: (context, index) {
        final text = _paragraphs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: _config.paragraphPadding),
          child: Text(
            '$indent${text.trim()}',
            style: TextStyle(
              fontSize: _config.fontSize,
              height: _config.lineHeight,
              color: Color(_config.textColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavBar() {
    final index = _item.durChapterIndex ?? 0;
    final name = _chapters.isEmpty
        ? ''
        : (_chapters[index.clamp(0, _chapters.length - 1)].name ?? '');
    return BottomAppBar(
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: index > 0 ? () => _openChapter(index - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: '上一章',
          ),
          Expanded(
            child: Text(
              '${index + 1}/${_chapters.length} $name',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed:
                index + 1 < _chapters.length ? () => _openChapter(index + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: '下一章',
          ),
        ],
      ),
    );
  }
}
