import 'package:flutter/material.dart';

import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_chats_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_feeds_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_friends_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_icon_badge.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_main_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_notifications_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_profile_page.dart';
import 'package:dashboard/features/chat/fluttersocialappuikit_demo/fluttersocialappuikit_theme.dart';

/// State of the FlutterSocialAppUIKit tab shell
/// (source `lib/views/screens/main_screen.dart:11-22`).
///
/// The source's five tabs are `Chats`, `Friends`, `Home`, `Notifications` and
/// `Profile`; it opens on `Home` (index 2), the page view cannot be swiped
/// (`NeverScrollableScrollPhysics`) and switching tabs calls
/// `PageController.jumpToPage` — there is no animation and no URL change. The
/// bottom-bar labels are empty strings in the source, so only the icons show.
class FlutterSocialAppUIKitMainPageState
    extends State<FlutterSocialAppUIKitMainPage> {
  late final PageController _pageController;
  int _page = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 2);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void didUpdateWidget(FlutterSocialAppUIKitMainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlutterSocialAppUIKitTheme.light(),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _page = page;
            });
          },
          children: const <Widget>[
            FlutterSocialAppUIKitChatsPage(),
            FlutterSocialAppUIKitFriendsPage(),
            FlutterSocialAppUIKitFeedsPage(),
            FlutterSocialAppUIKitNotificationsPage(),
            FlutterSocialAppUIKitProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _page,
          onTap: navigationTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(
              icon: FlutterSocialAppUIKitIconBadge(icon: Icons.notifications),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}
