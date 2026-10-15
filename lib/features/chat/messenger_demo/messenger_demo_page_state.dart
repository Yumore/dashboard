import 'package:dashboard/features/chat/messenger_demo/messenger_demo_calls_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_home_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_page.dart';
import 'package:dashboard/features/chat/messenger_demo/messenger_demo_placeholder_page.dart';
import 'package:flutter/material.dart';

class MessengerDemoPageState extends State<MessengerDemoPage> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageView(
      controller: _controller,
      onPageChanged: (index) => setState(() => _index = index),
      children: const [
        MessengerDemoHomePage(),
        MessengerDemoCallsPage(),
        MessengerDemoPlaceholderPage(title: 'Camera screen'),
        MessengerDemoPlaceholderPage(title: 'Stories screen'),
        MessengerDemoPlaceholderPage(title: 'Contacts screen'),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _index,
      selectedItemColor: const Color(0xFF2845E7),
      onTap: (index) => _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 10),
        curve: Curves.linear,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Stories'),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Contacts',
        ),
      ],
    ),
  );
}
