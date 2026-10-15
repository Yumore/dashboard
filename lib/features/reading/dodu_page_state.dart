import 'package:dashboard/features/reading/dodu_page.dart';
import 'package:flutter/material.dart';

class DoduPageState extends State<DoduPage> {
  static const _labels = ['书架', '书城', '我的'];
  static const _icons = ['bookshelf', 'bookstore', 'me'];
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('DoDu · ${_labels[_index]}')),
    body: switch (_index) {
      0 => RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('暂无书籍')),
          ],
        ),
      ),
      _ => Center(child: Text(_labels[_index])),
    },
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _index,
      onTap: (value) => setState(() => _index = value),
      items: [
        for (var index = 0; index < _labels.length; index++)
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/dodu/${_icons[index]}_normal.png',
              width: 24,
              height: 24,
            ),
            activeIcon: Image.asset(
              'assets/dodu/${_icons[index]}_selected.png',
              width: 24,
              height: 24,
            ),
            label: _labels[index],
          ),
      ],
    ),
  );
}
