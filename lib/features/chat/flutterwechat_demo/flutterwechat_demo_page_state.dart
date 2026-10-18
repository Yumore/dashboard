import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contacts_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_config.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_found_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_home_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_local_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_me_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_search_page.dart';
import 'package:flutter/material.dart';

/// State of the ported flutter-wechat shell.
class FlutterWechatDemoPageState extends State<FlutterWechatDemoPage> {
  static const List<({String normal, String active})> _tabIcons =
      <({String normal, String active})>[
        (
          normal: FlutterWechatAvailableImages.tabWeixinNormal,
          active: FlutterWechatAvailableImages.tabWeixinPressed,
        ),
        (
          normal: FlutterWechatAvailableImages.tabContactListNormal,
          active: FlutterWechatAvailableImages.tabContactListPressed,
        ),
        (
          normal: FlutterWechatAvailableImages.tabFindNormal,
          active: FlutterWechatAvailableImages.tabFindPressed,
        ),
        (
          normal: FlutterWechatAvailableImages.tabProfileNormal,
          active: FlutterWechatAvailableImages.tabProfilePressed,
        ),
      ];

  int _currentIndex = 0;

  /// The source kept each tab alive once it had been opened; an [IndexedStack]
  /// has the same effect without the lazy bookkeeping.
  late final List<Widget> _pages = <Widget>[
    const FlutterWechatHomePage(),
    const FlutterWechatContactsPage(),
    const FlutterWechatFoundPage(),
    const FlutterWechatMePage(),
  ];

  Future<void> _showAddMenu() async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    // The source anchored the menu at RelativeRect.fromLTRB(500, 76, 10, 0),
    // a hard-coded offset for its own screen; anchor it to the top-right here.
    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 200.0,
        56.0,
        10.0,
        0.0,
      ),
      color: FlutterWechatPalette.menuBackground,
      items: <PopupMenuEntry<String>>[
        _menuItem(
          value: 'groupChat',
          icon: const FlutterWechatLocalImage(
            FlutterWechatAvailableImages.menuGroup,
            width: 32.0,
            height: 32.0,
            fit: BoxFit.cover,
          ),
          title: '发起群聊',
        ),
        _menuItem(
          value: 'addFriend',
          icon: const FlutterWechatLocalImage(
            FlutterWechatAvailableImages.menuAddFriend,
            width: 32.0,
            height: 32.0,
            fit: BoxFit.cover,
          ),
          title: '添加朋友',
        ),
        _menuItem(
          value: 'scan',
          icon: const FlutterWechatLocalImage(
            FlutterWechatAvailableImages.menuScan,
            width: 32.0,
            height: 32.0,
            fit: BoxFit.cover,
          ),
          title: '扫一扫',
        ),
        _menuItem(
          value: 'pay',
          icon: const Icon(Icons.crop_free, color: Colors.white, size: 32.0),
          title: '收付款',
        ),
        _menuItem(
          value: 'feedback',
          icon: const Icon(Icons.email, color: Colors.white, size: 32.0),
          title: '帮助与反馈',
        ),
      ],
    );
    // The source showed a native toast for every choice; this demo always
    // stays on the current tab instead of faking a destination.
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required Widget icon,
    required String title,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          SizedBox(width: 32.0, height: 32.0, child: Center(child: icon)),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: FlutterWechatPalette.appBar,
        foregroundColor: Colors.white,
        title: Text(
          FlutterWechatDemoConfig.appTitle,
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: '搜索',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const FlutterWechatSearchPage(),
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: '添加',
            onPressed: _showAddMenu,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: FlutterWechatPalette.navigationSelected,
        unselectedItemColor: FlutterWechatPalette.navigationUnselected,
        onTap: (int index) => setState(() => _currentIndex = index),
        items: <BottomNavigationBarItem>[
          for (int i = 0; i < _tabIcons.length; i++)
            BottomNavigationBarItem(
              icon: FlutterWechatLocalImage(
                _tabIcons[i].normal,
                width: 32.0,
                height: 28.0,
                fit: BoxFit.cover,
              ),
              activeIcon: FlutterWechatLocalImage(
                _tabIcons[i].active,
                width: 32.0,
                height: 28.0,
                fit: BoxFit.cover,
              ),
              label: FlutterWechatDemoConfig.tabTitles[i],
            ),
        ],
      ),
    );
  }
}
