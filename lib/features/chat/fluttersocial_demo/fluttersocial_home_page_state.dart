import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_chats_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_feeds_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_home_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_notifications_page.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_profile_page.dart';
import 'package:flutter/material.dart';

/// Port of the source tab shell (source `lib/views/home.dart`).
///
/// The source's `LineIcons` glyphs were replaced with the closest Material
/// icons; the labels and the tab order are unchanged.
class FlutterSocialHomePageState extends State<FlutterSocialHomePage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    FlutterSocialFeedsPage(),
    FlutterSocialChatsPage(),
    FlutterSocialNotificationsPage(),
    FlutterSocialProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavBar = BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _currentIndex,
      selectedItemColor: FlutterSocialPalette.primaryColor,
      unselectedItemColor: Colors.grey.withValues(alpha: 0.6),
      elevation: 0.0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );

    return Scaffold(
      bottomNavigationBar: bottomNavBar,
      body: _pages[_currentIndex],
    );
  }
}
