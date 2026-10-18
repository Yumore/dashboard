import 'dart:math';

import 'package:dashboard/features/anime/animeone/animeone_detail_page.dart';
import 'package:dashboard/features/anime/animeone/animeone_entry.dart';
import 'package:dashboard/features/anime/animeone/animeone_entry_card.dart';
import 'package:dashboard/features/anime/animeone/animeone_error_button.dart';
import 'package:dashboard/features/anime/animeone/animeone_site_client.dart';
import 'package:dashboard/features/anime/animeone/animeone_watch_store.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimeOneDetailPageState extends State<AnimeOneDetailPage> {
  /// 站点每页固定 14 条，翻页判断依赖这个数字。
  static const int pageSize = 14;

  late final AnimeOneSiteClient _client;
  AnimeOneSiteClient? _ownedClient;
  late final AnimeOneWatchStore _store;

  final ScrollController controller = ScrollController();
  final List<AnimeOneEntry> entries = [];
  String fullLink = '';
  String title = '';
  String error = '';
  int page = 1;
  bool loading = true;
  bool hasMoreData = true;
  bool canLoadMore = true;

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? (_ownedClient = AnimeOneSiteClient());
    _store = widget.watchStore ?? AnimeOneWatchStore();
    fullLink = widget.link;
    title = widget.title ?? '';
    controller.addListener(loadMore);
    _getEntry();
  }

  @override
  void dispose() {
    controller.dispose();
    _ownedClient?.close();
    super.dispose();
  }

  /// 滚动到底部附近时加载下一页。
  void loadMore() {
    if (!controller.hasClients) return;
    if (controller.position.extentAfter < 10 &&
        entries.length % pageSize == 0 &&
        hasMoreData &&
        canLoadMore) {
      nextPage();
    }
  }

  /// 手动翻到下一页（测试与“加载更多”按钮共用）。
  Future<void> nextPage() async {
    if (loading) return;
    page += 1;
    await _getEntry();
  }

  Future<void> _getEntry() async {
    setState(() {
      canLoadMore = false;
      error = '';
    });
    try {
      final result = await _client.getPage(link: fullLink, page: page);
      if (!mounted) return;
      setState(() {
        entries.addAll(result.entries);
        if (result.title.isNotEmpty) title = result.title;
        final categoryLink = result.categoryLink;
        if (categoryLink != null && categoryLink.isNotEmpty) {
          fullLink = categoryLink;
        }
        hasMoreData = result.entries.length >= pageSize;
        if (_client.blocked) {
          hasMoreData = false;
          error = '访问被站点拒绝，请稍后再试';
        }
        loading = false;
        canLoadMore = true;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception.toString();
        loading = false;
        canLoadMore = true;
        hasMoreData = false;
      });
    }
  }

  /// 站内没有资料时跳到维基百科搜索。
  Future<void> _searchWikipedia() async {
    if (title.isEmpty) return;
    final uri = Uri.https('zh.wikipedia.org', '/w/index.php', {
      'search': title,
    });
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty && entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('加载失败 QAQ')),
        body: AnimeOneErrorButton(
          message: error,
          onRetry: () {
            setState(() {
              loading = true;
              page = 1;
              entries.clear();
            });
            _getEntry();
          },
        ),
      );
    }
    if (loading && entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title.isEmpty ? '加载中…' : title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title.isEmpty ? '动画目录' : title),
        actions: [
          if (title.isNotEmpty && widget.seasonal == null)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: '在维基百科搜索',
              onPressed: _searchWikipedia,
            ),
        ],
      ),
      body: entries.isEmpty
          ? const AnimeOneErrorButton(message: '没有找到相关结果')
          : _renderBody(),
    );
  }

  Widget _renderBody() {
    if (entries.length == 1) {
      return Center(
        child: SingleChildScrollView(
          child: AnimeOneEntryCard(
            entry: entries.first,
            showEpisode: true,
            client: widget.client,
            watchStore: _store,
          ),
        ),
      );
    }
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scaler = MediaQuery.textScalerOf(context);
          final count = max(
            min((constraints.maxWidth / scaler.scale(300)).floor(), 3),
            1,
          );
          final imageWidth = constraints.maxWidth / count;
          final offset = scaler.scale(widget.seasonal == null ? 93 : 125);
          final ratio = imageWidth / (imageWidth / 1.777 + offset);
          return Stack(
            children: [
              GridView.builder(
                key: ValueKey('grid_${count}_${ratio.toStringAsFixed(3)}'),
                controller: controller,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  childAspectRatio: ratio,
                ),
                itemCount: entries.length,
                itemBuilder: (context, index) => AnimeOneEntryCard(
                  entry: entries[index],
                  showEpisode: widget.seasonal != null,
                  client: widget.client,
                  watchStore: _store,
                ),
              ),
              if (!loading && !canLoadMore)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
