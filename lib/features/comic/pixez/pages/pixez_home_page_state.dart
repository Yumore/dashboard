import 'package:flutter/material.dart';

import '../controllers/pixez_home_controller.dart';
import '../pixez_load_status.dart';
import '../widgets/pixez_error_view.dart';
import '../widgets/pixez_illust_grid.dart';
import '../widgets/pixez_login_required_view.dart';
import '../widgets/pixez_token_dialog.dart';
import 'pixez_detail_page.dart';
import 'pixez_home_page.dart';
import 'pixez_rank_page.dart';
import 'pixez_search_page.dart';

class PixezHomePageState extends State<PixezHomePage> {
  late final PixezHomeController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PixezHomeController();
    if (_controller.status == PixezLoadStatus.idle) {
      _controller.load();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _enterToken() async {
    final token = await showPixezTokenDialog(context);
    if (!mounted || token == null) return;
    await _controller.auth.saveAccessToken(token);
    await _controller.load();
  }

  void _openDetail(int illustId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PixezDetailPage(illustId: illustId),
      ),
    );
  }

  void _openRank() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PixezRankPage()),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PixezSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixiv 推荐'),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: '排行榜',
            onPressed: _openRank,
            icon: const Icon(Icons.leaderboard_outlined),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: _controller.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.status == PixezLoadStatus.loginRequired) {
      return PixezLoginRequiredView(onEnterToken: _enterToken);
    }
    if (_controller.status == PixezLoadStatus.error &&
        _controller.illusts.isEmpty) {
      return PixezErrorView(
        message: _controller.error ?? '推荐加载失败',
        onRetry: _controller.load,
      );
    }
    if (_controller.illusts.isEmpty) {
      if (_controller.status == PixezLoadStatus.loading ||
          _controller.status == PixezLoadStatus.idle) {
        return const Center(child: CircularProgressIndicator());
      }
      return const Center(child: Text('没有推荐作品'));
    }
    return RefreshIndicator(
      onRefresh: _controller.load,
      child: PixezIllustGrid(
        illusts: _controller.illusts,
        physics: const AlwaysScrollableScrollPhysics(),
        loading: _controller.loadingMore,
        onLoadMore: _controller.loadMore,
        onTap: (illust) => _openDetail(illust.id),
      ),
    );
  }
}
