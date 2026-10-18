import 'package:flutter/material.dart';

import 'flutterwechatfull_conversation.dart';
import 'flutterwechatfull_demo_data.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_mainframe_page.dart';
import 'flutterwechatfull_remote_image.dart';
import 'flutterwechatfull_search_page.dart';
import 'flutterwechatfull_slidable.dart';
import 'flutterwechatfull_slidable_action.dart';
import 'flutterwechatfull_style.dart';

/// Faithful port of `MainframePage`: no conversation drill-down exists in the
/// source (the row `onTap` is commented out), so rows stay inert.
class FlutterWechatFullMainframePageState
    extends State<FlutterWechatFullMainframePage> {
  bool _menuOpen = false;

  static const List<FlutterWechatFullConversation> _conversations =
      FlutterWechatFullDemoData.conversations;

  void _openSearch() {
    // The source opens `SearchContent` as an in-place overlay; a zero-duration
    // route reproduces the same look without the push transition.
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => const FlutterWechatFullSearchPage(),
      ),
    );
  }

  void _closeMenu() {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
    }
  }

  List<FlutterWechatFullSlidableAction> _actionsFor(
    FlutterWechatFullConversation conversation,
  ) {
    const FlutterWechatFullSlidableAction delete =
        FlutterWechatFullSlidableAction(label: '删除', color: Color(0xFFFF0000));
    switch (conversation.type) {
      case '0':
        return <FlutterWechatFullSlidableAction>[delete];
      case '1':
        return <FlutterWechatFullSlidableAction>[
          const FlutterWechatFullSlidableAction(
            label: '标为未读',
            color: Color(0xFFC7C7CB),
          ),
          delete,
        ];
      default:
        return <FlutterWechatFullSlidableAction>[
          const FlutterWechatFullSlidableAction(
            label: '不再关注',
            color: Color(0xFFC7C7CB),
          ),
          delete,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      appBar: AppBar(
        backgroundColor: FlutterWechatFullStyle.background,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '微信',
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF181818),
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () => setState(() => _menuOpen = !_menuOpen),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: FlutterWechatFullLocalImage(
                path: FlutterWechatFullImages.addAction,
                width: 24.0,
                height: 24.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _buildSearchBar(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _conversations.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildRow(_conversations[index]),
                ),
              ),
            ],
          ),
          if (_menuOpen) ...<Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(color: Colors.black26),
              ),
            ),
            Positioned(top: 5.0, right: 10.0, child: _buildMenu()),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openSearch,
      child: Container(
        height: 36.0,
        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.search, size: 16.0, color: Color(0xFFB2B2B2)),
              SizedBox(width: 4.0),
              Text(
                '搜索',
                style: TextStyle(fontSize: 14.0, color: Color(0xFFB2B2B2)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(FlutterWechatFullConversation conversation) {
    return FlutterWechatFullSlidable(
      actions: _actionsFor(conversation),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildAvatars(conversation.avatars),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          conversation.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                            color: FlutterWechatFullStyle.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        FlutterWechatFullConversation.displayTime,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFFB2B2B2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          conversation.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Color(0xFF9B9B9B),
                          ),
                        ),
                      ),
                      if (conversation.messageFree)
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: FlutterWechatFullLocalImage(
                            path: FlutterWechatFullImages.mutedIcon,
                            width: 15.0,
                            height: 15.0,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatars(List<String> avatars) {
    if (avatars.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3.0),
        child: _buildAvatar(avatars.first, 48.0),
      );
    }
    final double size = avatars.length >= 5 ? 12.0 : 21.0;
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: const Color(0xFFDDDEE0),
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Center(
        child: SizedBox(
          width: 46.0,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 2.0,
            runSpacing: 2.0,
            children: <Widget>[
              for (final String avatar in avatars)
                ClipRRect(
                  borderRadius: BorderRadius.circular(1.0),
                  child: _buildAvatar(avatar, size),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url, double size) {
    if (url.startsWith('http')) {
      return FlutterWechatFullRemoteImage(url: url, width: size, height: size);
    }
    return FlutterWechatFullLocalImage(path: url, width: size, height: size);
  }

  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: FlutterWechatFullLocalImage(
            path: FlutterWechatFullImages.menuArrow,
            width: 15.0,
            height: 8.0,
          ),
        ),
        const SizedBox(height: 2.0),
        Container(
          width: 160.0,
          decoration: BoxDecoration(
            color: const Color(0xFF4C4C4C),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            children: <Widget>[
              _buildMenuItem('发起群聊', FlutterWechatFullImages.menuChats),
              _buildMenuDivider(),
              _buildMenuItem('添加朋友', FlutterWechatFullImages.menuAddFriend),
              _buildMenuDivider(),
              _buildMenuItem('扫一扫', FlutterWechatFullImages.menuScan),
              _buildMenuDivider(),
              _buildMenuItem('收付款', FlutterWechatFullImages.menuPay),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String label, String icon) {
    return InkWell(
      onTap: _closeMenu,
      child: SizedBox(
        height: 56.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Row(
            children: <Widget>[
              FlutterWechatFullLocalImage(
                path: icon,
                width: 20.0,
                height: 20.0,
              ),
              const SizedBox(width: 10.0),
              Text(
                label,
                style: const TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return const Divider(height: 0.5, indent: 56.0, color: Color(0x4DFFFFFF));
  }
}
