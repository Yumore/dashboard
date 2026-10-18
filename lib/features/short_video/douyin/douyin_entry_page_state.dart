import 'package:dashboard/features/short_video/douyin/douyin_api.dart';
import 'package:dashboard/features/short_video/douyin/douyin_entry_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_feed_page.dart';
import 'package:dashboard/features/short_video/douyin/douyin_signing_notice.dart';
import 'package:dashboard/features/short_video/douyin/douyin_user_post_page.dart';
import 'package:flutter/material.dart';

class DouyinEntryPageState extends State<DouyinEntryPage> {
  late final bool _ownsApi;
  late final DouyinApi _api;

  @override
  void initState() {
    super.initState();
    _ownsApi = widget.api == null;
    _api = widget.api ?? DouyinApi();
  }

  @override
  void dispose() {
    if (_ownsApi) {
      _api.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('抖音短视频')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.music_note_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '抖音短视频',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '移植自 flutter_app / flutter_app_cn / flutter_desktop：'
                    'creator.douyin.com 公开榜单、iesdouyin 作品信息、'
                    'aweme.snssdk.com 无水印播放地址，播放统一走宿主 MediaPlaybackPage。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const DouyinSigningNotice(),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.leaderboard_outlined),
              title: const Text('热门视频榜'),
              subtitle: const Text('creator.douyin.com 公开榜单 · 无水印播放地址'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openFeed,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_search_outlined),
              title: const Text('用户作品'),
              subtitle: const Text('tiktok.com /share/item/list · 需要有效 _signature'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openUserPosts,
            ),
          ),
        ],
      ),
    );
  }

  void _openFeed() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DouyinFeedPage(api: _api)),
    );
  }

  void _openUserPosts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DouyinUserPostPage(api: _api)),
    );
  }
}
