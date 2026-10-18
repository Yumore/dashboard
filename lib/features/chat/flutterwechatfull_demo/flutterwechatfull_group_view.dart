import 'package:flutter/material.dart';

import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_list_tile.dart';
import 'flutterwechatfull_style.dart';

/// Renders a [FlutterWechatFullGroup] with the source's hairline borders.
class FlutterWechatFullGroupView extends StatelessWidget {
  const FlutterWechatFullGroupView({required this.group, super.key});

  final FlutterWechatFullGroup group;

  @override
  Widget build(BuildContext context) {
    final Widget body = DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: FlutterWechatFullStyle.groupBorder,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: FlutterWechatFullStyle.groupBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < group.items.length; i++) ...<Widget>[
            if (i != 0)
              Divider(
                height: 0.5,
                color: FlutterWechatFullStyle.rowDivider,
                indent: _indentFor(group.items[i]),
              ),
            group.items[i],
          ],
        ],
      ),
    );

    final Widget header = group.header == null
        ? SizedBox(height: group.headerHeight)
        : Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
            child: Text(
              group.header!,
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF888888)),
            ),
          );

    final Widget footer = group.footer == null
        ? SizedBox(height: group.footerHeight)
        : Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
            child: Text(
              group.footer!,
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF888888)),
            ),
          );

    return Column(children: <Widget>[header, body, footer]);
  }

  double _indentFor(Widget item) {
    if (item is! FlutterWechatFullListTile) {
      return 16.0;
    }
    final FlutterWechatFullListTile tile = item;
    if (tile.center) {
      return 0.0;
    }
    if (tile.icon != null || tile.leading != null) {
      return 62.0;
    }
    return 16.0;
  }
}
