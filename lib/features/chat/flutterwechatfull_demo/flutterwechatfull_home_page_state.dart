import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'flutterwechatfull_contacts_page.dart';
import 'flutterwechatfull_discover_page.dart';
import 'flutterwechatfull_home_page.dart';
import 'flutterwechatfull_images.dart';
import 'flutterwechatfull_local_image.dart';
import 'flutterwechatfull_mainframe_page.dart';
import 'flutterwechatfull_profile_page.dart';
import 'flutterwechatfull_style.dart';

/// Mirrors `HomePage`: a non-scrollable PageView switched by a Cupertino tab
/// bar whose active tint is WeChat green.
class FlutterWechatFullHomePageState extends State<FlutterWechatFullHomePage> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    FlutterWechatFullMainframePage(),
    FlutterWechatFullContactsPage(),
    FlutterWechatFullDiscoverPage(),
    FlutterWechatFullProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatFullStyle.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: const Color(0xFFF7F7F7),
        activeColor: FlutterWechatFullStyle.primary,
        inactiveColor: const Color(0xFF191919),
        border: const Border(
          top: BorderSide(color: Color(0x33000000), width: 0.5),
        ),
        items: <BottomNavigationBarItem>[
          _tabItem(
            '微信',
            FlutterWechatFullImages.tabChats,
            FlutterWechatFullImages.tabChatsSelected,
          ),
          _tabItem(
            '通讯录',
            FlutterWechatFullImages.tabContacts,
            FlutterWechatFullImages.tabContactsSelected,
          ),
          _tabItem(
            '发现',
            FlutterWechatFullImages.tabDiscover,
            FlutterWechatFullImages.tabDiscoverSelected,
          ),
          _tabItem(
            '我',
            FlutterWechatFullImages.tabMe,
            FlutterWechatFullImages.tabMeSelected,
          ),
        ],
      ),
    );
  }

  static BottomNavigationBarItem _tabItem(
    String label,
    String icon,
    String activeIcon,
  ) {
    return BottomNavigationBarItem(
      label: label,
      icon: FlutterWechatFullLocalImage(path: icon, width: 26.0, height: 26.0),
      activeIcon: FlutterWechatFullLocalImage(
        path: activeIcon,
        width: 26.0,
        height: 26.0,
      ),
    );
  }
}
