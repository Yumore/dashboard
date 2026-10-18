import 'package:flutter/material.dart';

/// The four hard-coded message shortcuts in
/// `flutter_tiktok/lib/pages/msgPage.dart`.
class FlutterTiktokMessageEntry {
  const FlutterTiktokMessageEntry({
    required this.label,
    required this.icon,
    required this.colors,
    required this.title,
    required this.messageTitle,
    required this.messageDesc,
    required this.reverse,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
  final String title;
  final String messageTitle;
  final String messageDesc;
  final bool reverse;

  static const List<FlutterTiktokMessageEntry> entries =
      <FlutterTiktokMessageEntry>[
        FlutterTiktokMessageEntry(
          label: '粉丝',
          icon: Icons.person,
          colors: <Color>[Colors.indigo, Colors.green],
          title: '粉丝',
          messageTitle: '你的粉丝',
          messageDesc: '我是你的粉丝',
          reverse: false,
        ),
        FlutterTiktokMessageEntry(
          label: '赞',
          icon: Icons.golf_course,
          colors: <Color>[Colors.teal, Colors.blue],
          title: '赞',
          messageTitle: '你的粉丝',
          messageDesc: '给你点了个赞',
          reverse: false,
        ),
        FlutterTiktokMessageEntry(
          label: '@',
          icon: Icons.people,
          colors: <Color>[Colors.deepPurple, Colors.pink],
          title: '@',
          messageTitle: '你的粉丝',
          messageDesc: 'Ta提到了你',
          reverse: true,
        ),
        FlutterTiktokMessageEntry(
          label: '评论',
          icon: Icons.mode_comment,
          colors: <Color>[Colors.red, Colors.amber],
          title: '评论',
          messageTitle: '老铁双击666啊',
          messageDesc: '你的粉丝',
          reverse: true,
        ),
      ];
}
