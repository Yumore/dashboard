import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_count_formatter.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signing_notice.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_controller.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_page.dart';
import 'package:flutter/material.dart';

class DouyinUserPostPageState extends State<DouyinUserPostPage> {
  late final bool _ownsApi;
  late final DouyinApi _api;
  late final DouyinUserPostController _controller;
  late final TextEditingController _secUidController;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DouyinApi();
    _controller = widget.controller ?? DouyinUserPostController(api: _api);
    _secUidController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _secUidController.dispose();
    if (_ownsApi) {
      _api.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load(secUid: _secUidController.text);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _showSigningGap() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('签名不可用'),
        content: const SingleChildScrollView(child: DouyinSigningNotice()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('抖音用户作品'),
        actions: <Widget>[
          if (!_api.signingSupported)
            IconButton(
              tooltip: '签名不可用',
              icon: const Icon(Icons.lock_outline),
              onPressed: _showSigningGap,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            controller: _secUidController,
            decoration: const InputDecoration(
              labelText: 'secUid（留空则请求推荐流）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _controller.isLoading ? null : _load,
            icon: const Icon(Icons.search),
            label: const Text('获取用户作品'),
          ),
          if (_controller.isLoading) ...<Widget>[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('正在请求 /share/item/list…'),
          ],
          if (_controller.error != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              _controller.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          if (_controller.signatureRejected) ...<Widget>[
            const SizedBox(height: 12),
            const DouyinSigningNotice(),
          ],
          if (_controller.posts.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Text('共 ${_controller.posts.length} 条作品',
                style: theme.textTheme.titleSmall),
            for (final post in _controller.posts)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: post.authorAvatar.isEmpty
                        ? null
                        : NetworkImage(post.authorAvatar),
                    child: post.authorAvatar.isEmpty
                        ? const Icon(Icons.person_outline)
                        : null,
                  ),
                  title: Text(
                    post.displayDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${post.authorHandle} · ${post.musicLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DouyinCountFormatter.compact(post.diggCount),
                    semanticsLabel: '点赞',
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
