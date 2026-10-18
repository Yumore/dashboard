import 'package:dashboard/features/novel/flutternovel/api/zssq_api.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_book_source.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_chapter.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_detail_info.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_review.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_search_book.dart';
import 'package:dashboard/features/novel/flutternovel/models/novel_short_comment_doc.dart';
import 'package:dashboard/features/novel/flutternovel/models/star_rating.dart';
import 'package:dashboard/features/novel/flutternovel/page/flutternovel_reader_page.dart';
import 'package:dashboard/features/novel/flutternovel/page/novel_book_detail_controller.dart';
import 'package:dashboard/features/novel/flutternovel/page/novel_source_picker.dart';
import 'package:dashboard/features/novel/flutternovel/store/flutter_novel_store.dart';
import 'package:dashboard/features/novel/flutternovel/store/novel_chapter_cache.dart';
import 'package:flutter/material.dart';

/// 书籍详情 — the book intro, chapter list, short comments and reviews.
///
/// Everything is loaded by [NovelBookDetailController] from `initState`
/// callbacks; the widget's own `build` only renders the already-held state.
class FlutterNovelBookPage extends StatefulWidget {
  const FlutterNovelBookPage({
    super.key,
    required this.bookId,
    required this.api,
    required this.store,
    required this.cache,
    this.preview,
  });

  final String bookId;
  final ZssqApi api;
  final FlutterNovelStore store;
  final NovelChapterCache cache;

  /// The search/detail row the user tapped, shown while the detail loads.
  final NovelSearchBook? preview;

  @override
  State<FlutterNovelBookPage> createState() => _FlutterNovelBookPageState();
}

class _FlutterNovelBookPageState extends State<FlutterNovelBookPage> {
  late final NovelBookDetailController _detail = NovelBookDetailController(
    api: widget.api,
    store: widget.store,
    bookId: widget.bookId,
  );

  @override
  void initState() {
    super.initState();
    _detail.addListener(_onChanged);
    _detail.load();
  }

  @override
  void dispose() {
    _detail.removeListener(_onChanged);
    _detail.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  NovelDetailInfo? get _info => _detail.detail;

  String get _title => _info?.title ?? widget.preview?.title ?? widget.bookId;

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          if (_detail.sources.length > 1)
            IconButton(
              tooltip: '切换书源',
              onPressed: _showSourcePicker,
              icon: const Icon(Icons.swap_horiz),
            ),
        ],
      ),
      bottomNavigationBar: _bottomActions(),
      body: _detail.detailLoading && info == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                _header(info),
                _stats(info),
                const Divider(height: 32),
                _introSection(info),
                const Divider(height: 32),
                _reviewSection(),
                const Divider(height: 32),
                _chapterSection(),
                const Divider(height: 32),
                _commentSection(),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header / stats
  // ---------------------------------------------------------------------------

  Widget _header(NovelDetailInfo? info) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _cover(info?.cover ?? widget.preview?.cover, 96, 132),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                info?.author ?? widget.preview?.author ?? '佚名',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (info?.majorCate != null)
                Text('分类：${info!.majorCate}'),
              if (info?.tags != null && info!.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('标签：${info.tags.join(' / ')}'),
                ),
              const SizedBox(height: 8),
              _starRow(info),
              const SizedBox(height: 4),
              Text(
                info?.isSerial == true ? '连载中' : '已完结',
                style: const TextStyle(color: Colors.deepOrange),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _starRow(NovelDetailInfo? info) {
    final score = info?.rating?.score;
    final ratings = info?.starRatings ?? const <StarRating>[];
    final total = ratings.fold<int>(0, (sum, item) => sum + (item.count ?? 0));

    /// The API returns a five-bucket distribution; the average is the weighted
    /// mean of the bucket stars, which is what the source displayed.
    final weighted = total == 0
        ? 0.0
        : ratings.fold<double>(
                0,
                (sum, item) =>
                    sum + (item.star ?? 0) * (item.count ?? 0),
              ) /
              total;

    return Row(
      children: <Widget>[
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= ((score ?? weighted).round())
                ? Icons.star
                : Icons.star_border,
            size: 18,
            color: Colors.amber,
          ),
        const SizedBox(width: 6),
        Text(
          score == null
              ? (total == 0 ? '暂无评分' : weighted.toStringAsFixed(1))
              : score.toStringAsFixed(1),
        ),
        if (info?.starRatingCount != null)
          Text(
            ' (${info!.starRatingCount})',
            style: const TextStyle(color: Colors.black54),
          ),
      ],
    );
  }

  Widget _stats(NovelDetailInfo? info) {
    final items = <String, String>{
      '字数': _formatCount(info?.wordCount),
      '章节': '${info?.chaptersCount ?? _detail.catalog?.chapterCount ?? 0}',
      '追更': _formatCount(info?.followerCount),
      '留存': (info?.retentionRatio?.isNotEmpty ?? false)
          ? '${info!.retentionRatio}%'
          : '-',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          for (final entry in items.entries)
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(entry.key, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _formatCount(int? value) {
    if (value == null) return '-';
    if (value >= 10000) return '${(value / 10000).toStringAsFixed(1)}万';
    return '$value';
  }

  // ---------------------------------------------------------------------------
  // Intro / reviews
  // ---------------------------------------------------------------------------

  Widget _introSection(NovelDetailInfo? info) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('简介', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          (info?.longIntro?.isNotEmpty ?? false)
              ? info!.longIntro!
              : (info?.authorDesc ?? '暂无简介'),
        ),
        if (info?.lastChapter != null) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            '最新：${info!.lastChapter}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ],
    ),
  );

  Widget _reviewSection() {
    final review = _detail.review;
    final visible = review?.reviews.take(3).toList() ?? const <NovelReview>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('书评', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              if (review != null) Text('共 ${review.total} 条'),
              const Spacer(),
              if (_detail.hasMoreReviews)
                TextButton(
                  onPressed: () => _detail.loadReviews(reset: false),
                  child: const Text('加载更多'),
                ),
            ],
          ),
          if (_detail.reviewLoading && review == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_detail.reviewError != null)
            Text(_detail.reviewError!)
          else if (visible.isEmpty)
            const Text('还没有书评')
          else
            for (final item in visible)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.title?.isNotEmpty == true ? item.title! : '书评',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item.content ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${item.rating ?? '-'}星\n${item.likeCount ?? 0}赞',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chapters
  // ---------------------------------------------------------------------------

  Widget _chapterSection() {
    final catalog = _detail.catalog;
    final chapters = catalog?.chapters ?? const <NovelChapter>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('目录', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('共 ${chapters.length} 章'),
              const Spacer(),
              if (chapters.isNotEmpty)
                TextButton(
                  onPressed: () => _showCatalogSheet(chapters),
                  child: const Text('查看全部'),
                ),
            ],
          ),
          if (_detail.catalogLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_detail.catalogError != null)
            Row(
              children: <Widget>[
                Expanded(child: Text(_detail.catalogError!)),
                TextButton(
                  onPressed: _detail.loadCatalog,
                  child: const Text('重试'),
                ),
              ],
            )
          else
            for (var index = 0; index < chapters.take(30).length; index++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  chapters[index].title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openReader(index),
              ),
        ],
      ),
    );
  }

  void _showCatalogSheet(List<NovelChapter> chapters) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ListTile(
              title: Text(chapter.title ?? ''),
              onTap: () {
                Navigator.of(context).pop();
                _openReader(index);
              },
            );
          },
        ),
      ),
    );
  }

  void _showSourcePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: NovelSourcePicker(
          sources: _detail.sources,
          selectedId: _detail.sources.isEmpty ? null : _detail.sources.first.id,
          onSelected: (source) {
            Navigator.of(context).pop();
            _switchSource(source);
          },
        ),
      ),
    );
  }

  Future<void> _switchSource(NovelBookSource source) async {
    final result = await widget.api.getNovelCatalog(source.id ?? '');
    if (!mounted || !result.isSuccess || result.data == null) return;
    setState(() {
      _detail.catalog = result.data;
    });
  }

  // ---------------------------------------------------------------------------
  // Short comments
  // ---------------------------------------------------------------------------

  Widget _commentSection() {
    final comment = _detail.shortComment;
    final docs = comment?.docs.take(10).toList() ?? const <NovelShortCommentDoc>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('短评', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              if (comment != null) Text('今日 ${comment.today}'),
            ],
          ),
          if (_detail.commentLoading && comment == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_detail.commentError != null)
            Text(_detail.commentError!)
          else if (docs.isEmpty)
            const Text('还没有短评')
          else
            for (final doc in docs)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  doc.author?.nickname ?? '匿名',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  doc.content ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${doc.rating ?? '-'}星',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom actions / reader
  // ---------------------------------------------------------------------------

  Widget? _bottomActions() {
    final chapters = _detail.catalog?.chapters ?? const <NovelChapter>[];
    if (_detail.detailLoading && _info == null) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _detail.detail == null
                    ? null
                    : () => _toggleShelf(),
                icon: Icon(
                  _detail.onShelf ? Icons.bookmark : Icons.bookmark_border,
                ),
                label: Text(_detail.onShelf ? '已在书架' : '加入书架'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: chapters.isEmpty ? null : () => _openReader(0),
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始阅读'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleShelf() async {
    if (_detail.onShelf) {
      await _detail.removeFromShelf();
    } else {
      await _detail.addToShelf();
    }
  }

  Future<void> _openReader(int chapterOffset) async {
    final catalog = _detail.catalog;
    if (catalog == null || catalog.chapters.isEmpty) return;
    final target = chapterOffset.clamp(0, catalog.chapters.length - 1);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterNovelReaderPage(
          api: widget.api,
          store: widget.store,
          cache: widget.cache,
          bookId: widget.bookId,
          title: _title,
          catalog: catalog,
          chapterIndex: target,
        ),
      ),
    );
    if (mounted) _detail.refreshShelfState();
  }

  Widget _cover(String? url, double width, double height) => SizedBox(
    width: width,
    height: height,
    child: (url ?? '').isEmpty
        ? const ColoredBox(
            color: Color(0x22000000),
            child: Icon(Icons.book, size: 32),
          )
        : Image.network(
            url!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Color(0x22000000),
              child: Icon(Icons.book, size: 32),
            ),
          ),
  );
}
