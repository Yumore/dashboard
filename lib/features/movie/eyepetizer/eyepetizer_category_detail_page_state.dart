import 'dart:async';

import 'package:dashboard/features/movie/eyepetizer/eyepetizer_api.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_category_detail_page.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_collapse.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_exception.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_item.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_status_view.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_thumbnail.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_card.dart';
import 'package:dashboard/features/movie/eyepetizer/eyepetizer_video_detail_page.dart';
import 'package:flutter/material.dart';

class EyepetizerCategoryDetailPageState
    extends State<EyepetizerCategoryDetailPage> {
  late final EyepetizerApi _api;
  late final bool _ownsApi;

  final List<EyepetizerItem> _items = <EyepetizerItem>[];
  String? _nextPageUrl;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? EyepetizerApi();
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_ownsApi) _api.dispose();
    super.dispose();
  }

  /// Note: the source's `getData` did `itemList.addAll(issue.itemList)` even for
  /// a refresh, so pulling to refresh duplicated every row. The port clears
  /// first — the visible behaviour the source intended.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final issue = await _api.categoryVideos(widget.category.id);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(issue.itemList);
        _nextPageUrl = issue.nextPageUrl;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is EyepetizerException ? error.message : '加载失败，请重试';
      });
    }
  }

  Future<void> _loadMore() async {
    final next = _nextPageUrl;
    if (next == null || _loadingMore || _loading) return;
    setState(() => _loadingMore = true);
    try {
      final issue = await _api.categoryVideosPage(next);
      if (!mounted) return;
      setState(() {
        _items.addAll(issue.itemList);
        _nextPageUrl = issue.nextPageUrl;
        _loadingMore = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            error is EyepetizerException ? error.message : '加载失败，请重试',
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final title = widget.category.alias.isNotEmpty
        ? widget.category.alias
        : widget.category.name;
    final threshold = EyepetizerCollapse.collapseThresholdFor(
      MediaQuery.paddingOf(context).top,
    );
    final cover = widget.category.bgPicture.isNotEmpty
        ? widget.category.bgPicture
        : widget.category.headerImage;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 600) {
              unawaited(_loadMore());
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final light = EyepetizerCollapse.showsLightTitle(
                      height: constraints.biggest.height,
                      collapseThreshold: threshold,
                    );
                    return FlexibleSpaceBar(
                      titlePadding: const EdgeInsetsDirectional.only(
                        start: 56,
                        bottom: 16,
                        end: 16,
                      ),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: light ? Colors.white : Colors.black,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          EyepetizerThumbnail(url: cover, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.black38,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ..._buildSlivers(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    if (_loading) {
      return const <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EyepetizerStatusView.loading(),
        ),
      ];
    }
    final error = _error;
    if (error != null) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EyepetizerStatusView.error(error, onRetry: _load),
        ),
      ];
    }
    if (_items.isEmpty) {
      return const <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: EyepetizerStatusView.empty('这个分类下暂时没有视频'),
        ),
      ];
    }
    return <Widget>[
      SliverList.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return EyepetizerVideoCard(
            item: item,
            showCategory: false,
            showDivider: false,
            onTap: () => _openDetail(item),
          );
        },
      ),
      SliverToBoxAdapter(child: _footer(context)),
    ];
  }

  Widget _footer(BuildContext context) {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_nextPageUrl == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text('没有更多了', style: Theme.of(context).textTheme.bodySmall),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}
