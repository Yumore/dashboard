import 'package:dashboard/features/comic/manhuatai/manhuatai_chapter.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_comment_count.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_cover.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_detail_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_favorite.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_image_url.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_influence.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_library_store.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_reader_page.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_source.dart';
import 'package:dashboard/features/comic/manhuatai/manhuatai_status_view.dart';
import 'package:flutter/material.dart';

class ManhuataiDetailPageState extends State<ManhuataiDetailPage> {
  late final ManhuataiSource _source = widget.source ?? ManhuataiSource();
  late final ManhuataiLibraryStore _store =
      widget.store ?? ManhuataiLibraryStore();

  bool _loading = true;
  bool _favorite = false;
  bool _busyFavorite = false;
  String? _error;
  ManhuataiDetail? _detail;
  ManhuataiInfluence? _influence;
  ManhuataiCommentCount? _commentCount;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    if (widget.source == null) {
      _source.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await _source.detail(comicId: widget.comicId);
      // Influence and comment counts are decorative: the source tolerated
      // their failure and the detail still rendered.
      ManhuataiInfluence? influence;
      ManhuataiCommentCount? commentCount;
      try {
        influence = await _source.influence(comicId: widget.comicId);
      } catch (_) {
        influence = null;
      }
      try {
        commentCount = await _source.commentCount(comicId: widget.comicId);
      } catch (_) {
        commentCount = null;
      }
      final favorite = await _store.isFavorite(widget.comicId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _influence = influence;
        _commentCount = commentCount;
        _favorite = favorite;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final detail = _detail;
    if (detail == null || _busyFavorite) {
      return;
    }
    setState(() => _busyFavorite = true);
    final favorite = ManhuataiFavorite.fromDetail(
      detail,
      comicId: widget.comicId,
    );
    final nowFavorite = await _store.toggleFavorite(favorite);
    if (!mounted) {
      return;
    }
    setState(() {
      _favorite = nowFavorite;
      _busyFavorite = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nowFavorite ? '已加入书架' : '已移出书架')),
    );
  }

  /// [displayChapters] is the newest-first list rendered above; the reader gets
  /// the ascending order the source used (`comic_chapter` order).
  void _openReader(List<ManhuataiChapter> displayChapters, int displayIndex) {
    final chapter = displayChapters[displayIndex];
    if (chapter.islock == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该章节为付费章节，当前版本不提供购买')),
      );
      return;
    }
    final ascending = _detail?.comicChapter ?? displayChapters.reversed.toList();
    final index = ascending.indexWhere(
      (item) => item.chapterTopicId == chapter.chapterTopicId,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManhuataiReaderPage(
          comicId: widget.comicId,
          comicName: _detail?.comicName ?? '',
          chapters: ascending,
          initialIndex: index < 0 ? 0 : index,
          source: _source,
          store: _store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('漫画详情')),
        body: const ManhuataiStatusView(loading: true),
      );
    }
    final detail = _detail;
    if (_error != null || detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('漫画详情')),
        body: ManhuataiStatusView(message: _error ?? '加载失败', onRetry: _load),
      );
    }
    final chapters = detail.comicChapter.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(detail.comicName),
        actions: <Widget>[
          IconButton(
            tooltip: _favorite ? '取消收藏' : '收藏',
            icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _busyFavorite ? null : _toggleFavorite,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          _buildHeader(detail),
          _buildStats(detail),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: <Widget>[
                Text('章节列表', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('共 ${detail.comicChapter.length} 话'),
              ],
            ),
          ),
          ...List<Widget>.generate(chapters.length, (index) {
            final chapter = chapters[index];
            return ListTile(
              dense: true,
              leading: chapter.islock == 1
                  ? const Icon(Icons.lock_outline)
                  : const Icon(Icons.menu_book_outlined),
              title: Text(chapter.chapterName),
              onTap: () => _openReader(chapters, index),
            );
          }),
        ],
      ),
      floatingActionButton: chapters.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openReader(chapters, chapters.length - 1),
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始阅读'),
            ),
    );
  }

  Widget _buildHeader(ManhuataiDetail detail) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ManhuataiCover(
            url: ManhuataiImageUrl.cover(
              comicId: widget.comicId,
              imgUrl: detail.coverList.isEmpty ? '' : detail.coverList.first,
            ),
            width: 96,
            height: 128,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(detail.comicName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('作者：${detail.comicAuthor}'),
                Text(detail.updateStatusStr),
                if (detail.comicTypeNew.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: detail.comicTypeNew
                        .map((type) => Chip(label: Text(type.name)))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                Text(
                  detail.comicDesc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ManhuataiDetail detail) {
    final influence = _influence;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 4,
        children: <Widget>[
          Text('人气 ${ManhuataiImageUrl.formatNumber(detail.renqi)}'),
          Text('收藏 ${detail.shoucang}'),
          if (_commentCount != null) Text('评论 ${_commentCount!.data}'),
          if (influence != null)
            Text('影响力 ${influence.data.outList.length}'),
          Text('最后更新 ${detail.lastChapterName}'),
        ],
      ),
    );
  }
}
