import 'package:flutter/cupertino.dart';

import 'flutterwechatfull_group.dart';
import 'flutterwechatfull_group_view.dart';
import 'flutterwechatfull_list_tile.dart';

/// Builds a group of switch rows backed by a simple title→bool map.
class FlutterWechatFullSwitchGroup extends StatelessWidget {
  const FlutterWechatFullSwitchGroup({
    this.header,
    required this.values,
    required this.onChanged,
    this.footer,
    super.key,
  });

  final String? header;
  final String? footer;
  final Map<String, bool> values;
  final void Function(String title, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return FlutterWechatFullGroupView(
      group: FlutterWechatFullGroup(
        header: header,
        footer: footer,
        items: <FlutterWechatFullListTile>[
          for (final MapEntry<String, bool> entry in values.entries)
            FlutterWechatFullListTile(
              title: entry.key,
              showArrow: false,
              trailing: CupertinoSwitch(
                value: entry.value,
                activeTrackColor: const Color(0xFF57BE6A),
                onChanged: (bool value) => onChanged(entry.key, value),
              ),
            ),
        ],
      ),
    );
  }
}
