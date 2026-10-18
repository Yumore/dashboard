import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_select_text.dart';
import 'package:flutter/material.dart';

/// Port of `TikTokHeader` from `flutter_tiktok/lib/views/tikTokHeader.dart`.
class FlutterTiktokHeader extends StatelessWidget {
  const FlutterTiktokHeader({
    required this.selectedIndex,
    required this.onSelected,
    required this.onSearch,
    super.key,
  });

  static const List<String> tabs = <String>['推荐', '本地'];

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            key: const Key('fluttertiktok_header_search'),
            behavior: HitTestBehavior.opaque,
            onTap: onSearch,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.search,
                size: 28,
                color: FlutterTiktokPalette.white66,
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              for (int i = 0; i < tabs.length; i++)
                Expanded(
                  child: FlutterTiktokSelectText(
                    title: tabs[i],
                    isSelect: selectedIndex == i,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.tv,
                size: 28,
                color: FlutterTiktokPalette.white66,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
