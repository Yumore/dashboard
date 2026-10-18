import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_avatar.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_detail_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_entrance.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_list_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_mini_program_panel.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_seed_data.dart';
import 'package:flutter/material.dart';

class FakeWechatChatListPageState extends State<FakeWechatChatListPage> {
  void _openConversation(FakeWechatChatEntrance entrance) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FakeWechatChatDetailPage(friend: entrance.friend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FakeWechatDemoConfig.miniProgramBackground,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const FakeWechatMiniProgramPanel(),
          DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.15,
            maxChildSize: 1,
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: FakeWechatDemoConfig.headerYellow,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Column(
                  children: <Widget>[
                    _buildHeader(),
                    Expanded(
                      child: ColoredBox(
                        color: Colors.white,
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: FakeWechatSeedData.chatEntrances.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: FakeWechatDemoConfig.divider,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            final FakeWechatChatEntrance entrance =
                                FakeWechatSeedData.chatEntrances[index];
                            return _buildTile(
                              entrance,
                              onTap: () => _openConversation(entrance),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: <Widget>[
            const Text(
              FakeWechatDemoConfig.chatHeaderTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              tooltip: '搜索',
              onPressed: () {},
              icon: const Icon(Icons.search, color: Colors.black, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    FakeWechatChatEntrance entrance, {
    required VoidCallback onTap,
  }) {
    final recent = entrance.recentMessage;
    final preview = recent.text ?? FakeWechatDemoConfig.noRecentMessage;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14),
          child: Row(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  FakeWechatAvatar(name: entrance.name, size: 46),
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: FakeWechatDemoConfig.unreadRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        entrance.unreadLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entrance.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          recent.timestamp == null ? '' : '${recent.timestamp}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: FakeWechatDemoConfig.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: FakeWechatDemoConfig.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
