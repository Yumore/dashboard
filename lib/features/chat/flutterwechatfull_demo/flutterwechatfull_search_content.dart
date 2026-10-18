import 'package:flutter/material.dart';

/// `SearchContent`: six dead category cells plus the voice-input hint.
class FlutterWechatFullSearchContent extends StatelessWidget {
  const FlutterWechatFullSearchContent({super.key});

  static const List<List<String>> _rows = <List<String>>[
    <String>['朋友圈', '文章', '公众号'],
    <String>['小程序', '音乐', '表情'],
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48.0),
      child: Column(
        children: <Widget>[
          const Text(
            '搜索指定内容',
            style: TextStyle(fontSize: 15.0, color: Color(0xFFB1B1B1)),
          ),
          const SizedBox(height: 36.0),
          for (int row = 0; row < _rows.length; row++) ...<Widget>[
            Row(
              children: <Widget>[
                for (int column = 0; column < _rows[row].length; column++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 22.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: column == _rows[row].length - 1
                              ? null
                              : const Border(
                                  right: BorderSide(
                                    color: Color(0xFFC9C9C9),
                                    width: 0.5,
                                  ),
                                ),
                        ),
                        child: Text(
                          _rows[row][column],
                          style: const TextStyle(
                            fontSize: 17.0,
                            color: Color(0xFF576B94),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (row != _rows.length - 1) const SizedBox(height: 24.0),
          ],
          const Spacer(),
          Container(
            width: 57.0,
            height: 57.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_voice,
              size: 24.0,
              color: Color(0xFFA6A6A6),
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            '按住 说话',
            style: TextStyle(fontSize: 12.0, color: Color(0xFFA6A6A6)),
          ),
          const SizedBox(height: 60.0),
        ],
      ),
    );
  }
}
