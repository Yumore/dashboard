import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import '../controllers/pixez_detail_controller.dart';
import '../models/pixez_illust.dart';
import '../pixez_load_status.dart';
import '../widgets/pixez_error_view.dart';
import '../widgets/pixez_illust_grid.dart';
import '../widgets/pixez_login_required_view.dart';
import '../widgets/pixez_token_dialog.dart';
import 'pixez_detail_page.dart';
import 'pixez_user_page.dart';

class PixezDetailPageState extends State<PixezDetailPage> {
  late final PixezDetailController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        PixezDetailController(illustId: widget.illustId);
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

  void _openUser(int userId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PixezUserPage(userId: userId)),
    );
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
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final illust = _controller.illust;
        return Scaffold(
          appBar: AppBar(
            title: Text(illust?.title ?? '作品详情'),
            actions: <Widget>[
              if (illust != null)
                IconButton(
                  tooltip: _controller.bookmarked ? '取消收藏' : '收藏',
                  onPressed: _controller.actionBusy
                      ? null
                      : _controller.toggleBookmark,
                  icon: Icon(
                    _controller.bookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                ),
              IconButton(
                tooltip: '刷新',
                onPressed: _controller.load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.status == PixezLoadStatus.loginRequired) {
      return PixezLoginRequiredView(onEnterToken: _enterToken);
    }
    if (_controller.status == PixezLoadStatus.error) {
      return PixezErrorView(
        message: _controller.error ?? '作品加载失败',
        onRetry: _controller.load,
      );
    }
    final illust = _controller.illust;
    if (illust == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: <Widget>[
        _buildImages(illust),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                illust.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  InkWell(
                    onTap: () => _openUser(illust.user.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: illust.user.avatarUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) =>
                                const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(Icons.person_outline),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(illust.user.name),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _controller.actionBusy
                        ? null
                        : _controller.toggleFollow,
                    child: Text(_controller.following ? '已关注' : '关注'),
                  ),
                ],
              ),
              if (_controller.actionError != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _controller.actionError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final tag in illust.tags)
                    Chip(
                      label: Text(tag.translatedName ?? tag.name),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (_plainCaption(illust.caption).isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(_plainCaption(illust.caption)),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: <Widget>[
                  _stat(Icons.visibility_outlined, '${illust.totalView}'),
                  _stat(Icons.favorite_border, '${illust.totalBookmarks}'),
                  _stat(Icons.photo_library_outlined, '${illust.pageCount} 页'),
                  _stat(
                    Icons.aspect_ratio,
                    '${illust.width}×${illust.height}',
                  ),
                  _stat(Icons.event_outlined, illust.createDate),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '相关作品',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_controller.related.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('没有相关作品'),
                )
              else
                PixezIllustGrid(
                  illusts: _controller.related,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  onTap: (related) => _openDetail(related.id),
                ),
              if (_controller.hasMoreRelated)
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: _controller.loadingMoreRelated
                        ? null
                        : _controller.loadMoreRelated,
                    child: const Text('加载更多相关作品'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImages(PixezIllust illust) {
    if (illust.metaPages.isNotEmpty) {
      return SizedBox(
        height: 420,
        child: PageView.builder(
          itemCount: illust.metaPages.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: illust.metaPages[index].imageUrls.large,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            );
          },
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: illust.displayImageUrl,
      height: 420,
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }

  Widget _stat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }

  String _plainCaption(String caption) {
    final withoutTags = caption
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '');
    return HtmlUnescape().convert(withoutTags).trim();
  }
}
