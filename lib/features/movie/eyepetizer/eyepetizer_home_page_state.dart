import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_banner.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_home_feed.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_home_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_search_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_status_view.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_card.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page.dart';
import 'package:flutter/material.dart';

class EyepetizerHomePageState extends State<EyepetizerHomePage> {
  late final EyepetizerApi _api;
  late final bool _ownsApi;

  EyepetizerHomeFeed _feed = const EyepetizerHomeFeed();
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? EyepetizerApi();
    unawaited(_refresh());
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  /// First page, then immediately the second — the source did the same
  /// (`HomePageModel.refresh` -> `doExtraAfterRefresh` -> `loadMore`).
  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entity = await _api.feed();
      if (!mounted) return;
      setState(() {
        _feed = EyepetizerHomeFeed.firstPage(entity);
        _loading = false;
      });
      await _loadMore();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _messageOf(error);
      });
    }
  }

  Future<void> _loadMore() async {
    final next = _feed.nextPageUrl;
    if (next == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final entity = await _api.feedPage(next);
      if (!mounted) return;
      setState(() {
        _feed = _feed.appendPage(entity);
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      _showMessage(_messageOf(error));
    }
  }

  String _messageOf(Object error) =>
      error is EyepetizerException ? error.message : '加载失败，请重试';

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _openDetail(EyepetizerItem item) {
    final data = item.data;
    if (data == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EyepetizerVideoDetailPage(data: data, api: _api),
      ),
    );
  }

  void _openCategories() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EyepetizerCategoryPage(api: _api),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EyepetizerSearchPage(api: _api),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开眼 · Eyepetizer'),
        actions: <Widget>[
          IconButton(
            tooltip: '分类',
            icon: const Icon(Icons.grid_view_outlined),
            onPressed: _openCategories,
          ),
          IconButton(
            tooltip: '搜索',
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const EyepetizerStatusView.loading();
    final error = _error;
    if (error != null) {
      return EyepetizerStatusView.error(error, onRetry: _refresh);
    }
    if (_feed.banner.isEmpty && _feed.items.length <= 1) {
      return const EyepetizerStatusView.empty('首页暂时没有内容');
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 600) unawaited(_loadMore());
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _feed.items.length,
          itemBuilder: _buildRow,
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    if (index == 0) {
      if (_feed.banner.isEmpty) return const SizedBox.shrink();
      return EyepetizerBanner(
        items: _feed.banner,
        autoPlay: widget.bannerAutoPlay,
        onTap: _openDetail,
      );
    }
    final item = _feed.items[index];
    if (item.isTextHeader) return _sectionHeader(context, item.headerText);
    return EyepetizerVideoCard(item: item, onTap: () => _openDetail(item));
  }

  /// The source drew `textHeader` rows as a title followed by a hairline
  /// (`home_tab_page.dart`, `_headerView`).
  Widget _sectionHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
      child: Row(
        children: <Widget>[
          Text(text.isEmpty ? '精选' : text, style: theme.textTheme.titleSmall),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1)),
        ],
      ),
    );
  }
}
