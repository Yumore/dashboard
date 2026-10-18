import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_chat_list_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_contacts_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_config.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_demo_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_discovery_page.dart';
import 'package:dashboard/features/chat/fakewechat_demo/fakewechat_profile_page.dart';
import 'package:flutter/material.dart';

class FakeWechatDemoPageState extends State<FakeWechatDemoPage> {
  static const List<Widget> _pages = <Widget>[
    FakeWechatChatListPage(),
    FakeWechatContactsPage(),
    FakeWechatDiscoveryPage(),
    FakeWechatProfilePage(),
  ];

  static const List<BottomNavigationBarItem> _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '聊天'),
    BottomNavigationBarItem(icon: Icon(Icons.contacts), label: '联系人'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: '发现'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '我'),
  ];

  final PageController _pageController = PageController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FakeWechatDemoConfig.pageBackground,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: _currentIndex,
        selectedItemColor: FakeWechatDemoConfig.wechatGreen,
        unselectedItemColor: const Color(0xFF7A7E83),
        onTap: _selectTab,
      ),
    );
  }
}
