import 'package:dashboard/features/anime/tsdm/tsdm_cookie_store.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_group.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_group_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_page.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_forum_repository.dart';
import 'package:dashboard/features/anime/tsdm/tsdm_http_client.dart';
import 'package:flutter/material.dart';

/// State of [TsdmForumGroupPage].
class TsdmForumGroupPageState extends State<TsdmForumGroupPage> {
  TsdmHttpClient? _ownedClient;
  late final TsdmForumRepository _repository;
  TsdmForumGroup? group;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final client =
        widget.client ??
        (_ownedClient = TsdmHttpClient(cookieStore: TsdmCookieStore()));
    _repository = widget.repository ?? TsdmForumRepository(client: client);
    _load();
  }

  @override
  void dispose() {
    _ownedClient?.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await _repository.fetchForumGroup(widget.gid);
      if (!mounted) {
        return;
      }
      setState(() {
        group = result;
        loading = false;
        if (result == null) {
          error = '没有找到版块组';
        }
      });
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? widget.title ?? '版块组 ${widget.gid}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!),
            const SizedBox(height: 8),
            FilledButton(onPressed: _load, child: const Text('重试')),
          ],
        ),
      );
    }
    final forums = group?.forumList ?? const <TsdmForum>[];
    if (forums.isEmpty) {
      return const Center(child: Text('没有版块'));
    }
    return ListView.builder(
      itemCount: forums.length,
      itemBuilder: (context, index) {
        final forum = forums[index];
        return ListTile(
          leading: forum.iconUrl.isEmpty
              ? null
              : Image.network(forum.iconUrl, width: 32, height: 32),
          title: Text(forum.name),
          subtitle: Text('主题 ${forum.threadCount} · 回复 ${forum.replyCount}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  TsdmForumPage(fid: '${forum.forumID}', title: forum.name),
            ),
          ),
        );
      },
    );
  }
}
