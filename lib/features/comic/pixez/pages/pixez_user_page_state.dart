import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controllers/pixez_user_controller.dart';
import '../pixez_load_status.dart';
import '../widgets/pixez_error_view.dart';
import '../widgets/pixez_illust_grid.dart';
import '../widgets/pixez_login_required_view.dart';
import '../widgets/pixez_token_dialog.dart';
import 'pixez_detail_page.dart';
import 'pixez_user_page.dart';

class PixezUserPageState extends State<PixezUserPage> {
  late final PixezUserController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? PixezUserController(userId: widget.userId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_controller.detail?.user.name ?? '作者主页')),
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
        _controller.detail == null) {
      return PixezErrorView(
        message: _controller.error ?? '作者信息加载失败',
        onRetry: _controller.load,
      );
    }
    final detail = _controller.detail;
    if (detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final works = _controller.tabIndex == 2
        ? _controller.bookmarks
        : _controller.works;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: detail.user.avatarUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox(
                    width: 72,
                    height: 72,
                    child: Icon(Icons.person_outline, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      detail.user.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '@${detail.user.account}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: <Widget>[
                        _stat('作品', detail.profile.totalIllusts),
                        _stat('漫画', detail.profile.totalManga),
                        _stat('收藏', detail.profile.totalIllustBookmarksPublic),
                        _stat('关注', detail.profile.totalFollowUsers),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<int>>[
            ButtonSegment<int>(value: 0, label: Text('作品')),
            ButtonSegment<int>(value: 1, label: Text('漫画')),
            ButtonSegment<int>(value: 2, label: Text('收藏')),
          ],
          selected: <int>{_controller.tabIndex},
          onSelectionChanged: (selection) =>
              _controller.selectTab(selection.first),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _controller.tabLoading
              ? const Center(child: CircularProgressIndicator())
              : PixezIllustGrid(
                  illusts: works,
                  loading: _controller.loadingMore,
                  onLoadMore: _controller.loadMore,
                  onTap: (illust) => _openDetail(illust.id),
                ),
        ),
      ],
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
