import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_celebrity_works.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_data_source.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_load_state.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_photo.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_poster.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_provenance_banner.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_rating_bar.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_source_factory.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_status_view.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_subject_page.dart';
import 'package:dashboard/features/movie/flutterdouban/flutterdouban_work.dart';
import 'package:flutter/material.dart';

/// State for [FlutterDouBanCelebrityPage].
///
/// Loads the profile and the `/works` list in parallel from `initState`.
class FlutterDouBanCelebrityPageState
    extends State<FlutterDouBanCelebrityPage> {
  late final FlutterDouBanDataSource _source = createFlutterDouBanSource(
    useNetData: widget.useNetData,
    dio: widget.dio,
    assetLoader: widget.assetLoader,
  );

  final FlutterDouBanLoadState<FlutterDouBanCelebrity> _celebrity =
      FlutterDouBanLoadState<FlutterDouBanCelebrity>();
  final FlutterDouBanLoadState<FlutterDouBanCelebrityWorks> _works =
      FlutterDouBanLoadState<FlutterDouBanCelebrityWorks>();

  @override
  void initState() {
    super.initState();
    _loadCelebrity();
    _loadWorks();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _loadCelebrity() async {
    if (_celebrity.loading) return;
    setState(() {
      _celebrity.loading = true;
      _celebrity.error = null;
    });
    try {
      final data = await _source.celebrity(widget.celebrityId);
      if (!mounted) return;
      setState(() {
        _celebrity.data = data;
        _celebrity.error = null;
        _celebrity.loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _celebrity.error = error;
        _celebrity.loading = false;
      });
    }
  }

  Future<void> _loadWorks() async {
    if (_works.loading) return;
    setState(() {
      _works.loading = true;
      _works.error = null;
    });
    try {
      final data = await _source.celebrityWorks(widget.celebrityId);
      if (!mounted) return;
      setState(() {
        _works.data = data;
        _works.error = null;
        _works.loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _works.error = error;
        _works.loading = false;
      });
    }
  }

  void _openSubject(FlutterDouBanSubject subject) {
    if (subject.id.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FlutterDouBanSubjectPage(
          subjectId: subject.id,
          title: subject.displayTitle,
          useNetData: widget.useNetData,
          dio: widget.dio,
          assetLoader: widget.assetLoader,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final celebrity = _celebrity.data?.value;
    final title = celebrity == null || celebrity.name.isEmpty
        ? widget.name
        : celebrity.name;
    return Scaffold(
      appBar: AppBar(title: Text(title.isEmpty ? '影人' : title)),
      body: _body(),
    );
  }

  Widget _body() {
    if (_celebrity.loading && !_celebrity.hasData) {
      return const FlutterDouBanStatusView.loading();
    }
    if (_celebrity.hasError && !_celebrity.hasData) {
      return FlutterDouBanStatusView.error(
        '加载失败：${_celebrity.error}',
        onRetry: _loadCelebrity,
      );
    }
    final data = _celebrity.data;
    if (data == null) return const FlutterDouBanStatusView.loading();
    final celebrity = data.value;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        FlutterDouBanProvenanceBanner(data: data),
        _header(celebrity),
        _sectionTitle('简介'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(celebrity.hasSummary ? celebrity.summary : '暂无简介'),
        ),
        if (celebrity.photos.isNotEmpty) ...[
          _sectionTitle('相册'),
          _photoStrip(celebrity.photos),
        ],
        _sectionTitle('作品'),
        _worksSection(celebrity),
      ],
    );
  }

  Widget _header(FlutterDouBanCelebrity celebrity) {
    final theme = Theme.of(context);
    final aka = celebrity.akaAll;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlutterDouBanPoster(url: celebrity.avatarUrl, width: 96, height: 128),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  celebrity.name.isEmpty ? '未知影人' : celebrity.name,
                  style: theme.textTheme.titleMedium,
                ),
                if (celebrity.nameEn.isNotEmpty)
                  Text(celebrity.nameEn, style: theme.textTheme.bodySmall),
                if (celebrity.professionsText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '职业：${celebrity.professionsText}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (celebrity.profileLine.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      celebrity.profileLine,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (aka.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '更多外文名：${aka.join(" / ")}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoStrip(List<FlutterDouBanPhoto> photos) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) =>
            FlutterDouBanPoster(url: photos[index].url, width: 80, height: 104),
      ),
    );
  }

  Widget _worksSection(FlutterDouBanCelebrity celebrity) {
    final works = _works.data?.value.works ?? celebrity.works;
    final loading = _works.loading && works.isEmpty;
    final error = _works.error;
    if (loading) return const FlutterDouBanStatusView.loading();
    if (works.isEmpty && error != null) {
      return FlutterDouBanStatusView.error(
        '作品加载失败：$error',
        onRetry: _loadWorks,
      );
    }
    if (works.isEmpty) return const FlutterDouBanStatusView.empty('暂无作品');
    return Column(
      children: [
        if (_works.data != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '作品来源：${_works.data!.label}（共 ${_works.data!.value.total} 部）',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        for (final work in works) _workTile(work),
      ],
    );
  }

  Widget _workTile(FlutterDouBanWork work) {
    final subject = work.subject;
    if (subject == null) return const SizedBox.shrink();
    return ListTile(
      leading: FlutterDouBanPoster(
        url: subject.posterUrl,
        width: 44,
        height: 62,
      ),
      title: Text(subject.displayTitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (work.rolesText.isNotEmpty) Text('饰演：${work.rolesText}'),
          if (subject.rating.average > 0)
            FlutterDouBanRatingBar(average: subject.rating.average, size: 12),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openSubject(subject),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
    child: Text(title, style: Theme.of(context).textTheme.titleSmall),
  );
}
