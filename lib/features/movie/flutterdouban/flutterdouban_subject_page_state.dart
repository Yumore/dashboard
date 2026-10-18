import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_summary.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_comment.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_load_state.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_poster.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_provenance_banner.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_rating_bar.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_review.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_factory.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_status_view.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_detail.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_trailer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// State for [FlutterDouBanSubjectPage].
///
/// Three independent requests (detail, short comments, long reviews) are all
/// kicked off in [initState]; `build` only reads state.
class FlutterDouBanSubjectPageState extends State<FlutterDouBanSubjectPage> {
  late final FlutterDouBanDataSource _source = createFlutterDouBanSource(
    useNetData: widget.useNetData,
    dio: widget.dio,
    assetLoader: widget.assetLoader,
  );

  final FlutterDouBanLoadState<FlutterDouBanSubjectDetail> _detail =
      FlutterDouBanLoadState<FlutterDouBanSubjectDetail>();

  final List<FlutterDouBanComment> _comments = <FlutterDouBanComment>[];
  bool _commentsLoading = false;
  bool _commentsLoaded = false;
  Object? _commentsError;
  int? _commentsNextStart;
  int _commentsTotal = 0;
  String? _commentsOrigin;

  final List<FlutterDouBanReview> _reviews = <FlutterDouBanReview>[];
  bool _reviewsLoading = false;
  bool _reviewsLoaded = false;
  Object? _reviewsError;
  int? _reviewsNextStart;
  int _reviewsTotal = 0;
  String? _reviewsOrigin;

  bool get _commentsHasMore => _commentsNextStart != null;
  bool get _reviewsHasMore => _reviewsNextStart != null;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadComments(refresh: true);
    _loadReviews(refresh: true);
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    if (_detail.loading) return;
    setState(() {
      _detail.loading = true;
      _detail.error = null;
    });
    try {
      final data = await _source.subject(widget.subjectId);
      if (!mounted) return;
      setState(() {
        _detail.data = data;
        _detail.error = null;
        _detail.loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _detail.error = error;
        _detail.loading = false;
      });
    }
  }

  Future<void> _loadComments({required bool refresh}) async {
    if (_commentsLoading) return;
    if (!refresh && !_commentsHasMore) return;
    final start = refresh ? 0 : (_commentsNextStart ?? 0);
    setState(() {
      _commentsLoading = true;
      _commentsError = null;
    });
    try {
      final data = await _source.subjectComments(
        widget.subjectId,
        start: start,
      );
      if (!mounted) return;
      setState(() {
        _commentsLoading = false;
        _commentsLoaded = true;
        _commentsOrigin = data.label;
        if (refresh) _comments.clear();
        _comments.addAll(data.value.comments);
        _commentsTotal = data.value.total;
        _commentsNextStart = data.value.hasMore ? data.value.nextStart : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _commentsError = error;
        _commentsLoading = false;
        _commentsLoaded = true;
      });
    }
  }

  Future<void> _loadReviews({required bool refresh}) async {
    if (_reviewsLoading) return;
    if (!refresh && !_reviewsHasMore) return;
    final start = refresh ? 0 : (_reviewsNextStart ?? 0);
    setState(() {
      _reviewsLoading = true;
      _reviewsError = null;
    });
    try {
      final data = await _source.subjectReviews(widget.subjectId, start: start);
      if (!mounted) return;
      setState(() {
        _reviewsLoading = false;
        _reviewsLoaded = true;
        _reviewsOrigin = data.label;
        if (refresh) _reviews.clear();
        _reviews.addAll(data.value.reviews);
        _reviewsTotal = data.value.total;
        _reviewsNextStart = data.value.hasMore ? data.value.nextStart : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reviewsError = error;
        _reviewsLoading = false;
        _reviewsLoaded = true;
      });
    }
  }

  void _openCelebrity(FlutterDouBanCelebritySummary member) {
    if (!member.hasId) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterDouBanCelebrityPage(
          celebrityId: member.id,
          name: member.name,
          useNetData: widget.useNetData,
          dio: widget.dio,
          assetLoader: widget.assetLoader,
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail.data?.value;
    final title = detail == null || detail.title.isEmpty
        ? widget.title
        : detail.displayTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title.isEmpty ? '条目详情' : title)),
      body: _body(),
    );
  }

  Widget _body() {
    if (_detail.loading && !_detail.hasData) {
      return const FlutterDouBanStatusView.loading();
    }
    if (_detail.hasError && !_detail.hasData) {
      return FlutterDouBanStatusView.error(
        '加载失败：${_detail.error}',
        onRetry: _loadDetail,
      );
    }
    final data = _detail.data;
    if (data == null) return const FlutterDouBanStatusView.loading();
    final detail = data.value;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        FlutterDouBanProvenanceBanner(data: data),
        _header(detail),
        _sectionTitle('简介'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(detail.hasSummary ? detail.summary : '该条目暂无简介'),
        ),
        if (detail.castMembers.isNotEmpty) ...[
          _sectionTitle('影人'),
          _castStrip(detail.castMembers),
        ],
        if (detail.allClips.isNotEmpty) ...[
          _sectionTitle('预告片 / 片段'),
          for (final clip in detail.allClips) _clipTile(clip),
        ],
        _sectionTitle('短评'),
        _commentsSection(),
        _sectionTitle('长评'),
        _reviewsSection(),
      ],
    );
  }

  Widget _header(FlutterDouBanSubjectDetail detail) {
    final theme = Theme.of(context);
    final meta = <String>[
      if (detail.genresText.isNotEmpty) detail.genresText,
      if (detail.durationsText.isNotEmpty) detail.durationsText,
      if (detail.pubdatesText.isNotEmpty) '上映：${detail.pubdatesText}',
      if (detail.countries.isNotEmpty) '国家/地区：${detail.countries.join(" / ")}',
      if (detail.languages.isNotEmpty) '语言：${detail.languages.join(" / ")}',
      if (detail.collectCount > 0) '看过：${detail.collectCount}',
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlutterDouBanPoster(
            url: detail.images.preferred,
            width: 110,
            height: 154,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title.isEmpty ? '未知条目' : detail.title,
                  style: theme.textTheme.titleMedium,
                ),
                if (detail.originalTitle.isNotEmpty)
                  Text(detail.originalTitle, style: theme.textTheme.bodySmall),
                if (detail.year.isNotEmpty)
                  Text(detail.year, style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                FlutterDouBanRatingBar(average: detail.rating.average),
                for (final line in meta)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(line, style: theme.textTheme.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _castStrip(List<FlutterDouBanCelebritySummary> members) {
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final member = members[index];
          return InkWell(
            onTap: member.hasId ? () => _openCelebrity(member) : null,
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  FlutterDouBanPoster(
                    url: member.avatarUrl,
                    width: 64,
                    height: 88,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _clipTile(FlutterDouBanTrailer clip) {
    return ListTile(
      leading: FlutterDouBanPoster(
        url: clip.imageUrl,
        width: 56,
        height: 36,
        borderRadius: 4,
      ),
      title: Text(clip.title.isEmpty ? '片段' : clip.title),
      subtitle: clip.resourceUrl.isEmpty
          ? null
          : Text(
              clip.resourceUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.play_circle_outline),
      onTap: clip.resourceUrl.isEmpty ? null : () => _openUrl(clip.resourceUrl),
    );
  }

  Widget _commentsSection() {
    if (_commentsLoading && _comments.isEmpty) {
      return const FlutterDouBanStatusView.loading();
    }
    if (_commentsError != null && _comments.isEmpty) {
      return FlutterDouBanStatusView.error(
        '短评加载失败：$_commentsError',
        onRetry: () => _loadComments(refresh: true),
      );
    }
    if (!_commentsLoaded) return const FlutterDouBanStatusView.loading();
    if (_comments.isEmpty) return const FlutterDouBanStatusView.empty('暂无短评');
    return Column(
      children: [
        _originLine('短评', _commentsOrigin),
        for (final comment in _comments) _commentCard(comment),
        _loadMoreRow(
          loading: _commentsLoading,
          hasMore: _commentsHasMore,
          onPressed: () => _loadComments(refresh: false),
          label: '加载更多短评',
          tail: '已显示全部 $_commentsTotal 条短评',
        ),
      ],
    );
  }

  Widget _reviewsSection() {
    if (_reviewsLoading && _reviews.isEmpty) {
      return const FlutterDouBanStatusView.loading();
    }
    if (_reviewsError != null && _reviews.isEmpty) {
      return FlutterDouBanStatusView.error(
        '长评加载失败：$_reviewsError',
        onRetry: () => _loadReviews(refresh: true),
      );
    }
    if (!_reviewsLoaded) return const FlutterDouBanStatusView.loading();
    if (_reviews.isEmpty) return const FlutterDouBanStatusView.empty('暂无长评');
    return Column(
      children: [
        _originLine('长评', _reviewsOrigin),
        for (final review in _reviews) _reviewCard(review),
        _loadMoreRow(
          loading: _reviewsLoading,
          hasMore: _reviewsHasMore,
          onPressed: () => _loadReviews(refresh: false),
          label: '加载更多长评',
          tail: '已显示全部 $_reviewsTotal 条长评',
        ),
      ],
    );
  }

  Widget _originLine(String label, String? origin) {
    if (origin == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$label来源：$origin',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }

  Widget _commentCard(FlutterDouBanComment comment) {
    final theme = Theme.of(context);
    final author = comment.author;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FlutterDouBanPoster(
                  url: author.avatarUrl,
                  width: 28,
                  height: 28,
                  borderRadius: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    author.name.isEmpty ? '匿名用户' : author.name,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                FlutterDouBanRatingBar(
                  average: comment.rating.value,
                  max: comment.rating.max,
                  size: 12,
                  showText: false,
                ),
                Text(
                  ' 有用 ${comment.usefulText}',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(comment.content),
            ),
            if (comment.createdAt.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  comment.createdAt,
                  style: theme.textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(FlutterDouBanReview review) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.title.isEmpty ? '无标题' : review.title,
              style: theme.textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  FlutterDouBanRatingBar(
                    average: review.rating.value,
                    max: review.rating.max,
                    size: 12,
                    showText: false,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.author.name.isEmpty ? '匿名用户' : review.author.name,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                review.displaySummary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '有用 ${review.usefulCount} · 回复 ${review.commentsCount}'
                '${review.createdAt.isEmpty ? '' : ' · ${review.createdAt}'}',
                style: theme.textTheme.labelSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadMoreRow({
    required bool loading,
    required bool hasMore,
    required VoidCallback onPressed,
    required String label,
    required String tail,
  }) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (hasMore) {
      return Center(
        child: TextButton(onPressed: onPressed, child: Text(label)),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Text(tail, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}
