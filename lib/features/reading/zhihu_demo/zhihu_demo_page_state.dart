import 'package:dashboard/features/reading/zhihu_demo/zhihu_demo_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_home_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_my_page.dart';
import 'package:dashboard/features/reading/zhihu_demo/zhihu_placeholder_page.dart';
import 'package:flutter/material.dart';

class ZhihuDemoPageState extends State<ZhihuDemoPage> {
  int _index = 0;
  bool _dark = true;

  @override
  Widget build(BuildContext context) => Theme(
    data: _dark ? ThemeData.dark() : ThemeData.light(),
    child: Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const ZhihuHomePage(),
          const ZhihuPlaceholderPage(title: '想法'),
          const ZhihuPlaceholderPage(title: '市场'),
          const ZhihuPlaceholderPage(title: '通知'),
          ZhihuMyPage(
            dark: _dark,
            onToggleTheme: () => setState(() => _dark = !_dark),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.all_inclusive), label: '想法'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: '市场',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_alert), label: '通知'),
          BottomNavigationBarItem(icon: Icon(Icons.perm_identity), label: '我的'),
        ],
      ),
    ),
  );
}
