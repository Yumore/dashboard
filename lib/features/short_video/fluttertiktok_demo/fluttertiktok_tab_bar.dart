import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_select_text.dart';
import 'package:flutter/material.dart';

/// Source `TikTokPageTag` from `flutter_tiktok/lib/views/tiktokTabBar.dart`.
enum FlutterTiktokTab { home, follow, msg, me }

/// Port of `TikTokTabBar` from `flutter_tiktok/lib/views/tiktokTabBar.dart`.
class FlutterTiktokTabBar extends StatelessWidget {
  const FlutterTiktokTabBar({
    required this.current,
    required this.onSwitch,
    required this.onAdd,
    this.hasBackground = true,
    super.key,
  });

  final FlutterTiktokTab current;
  final ValueChanged<FlutterTiktokTab> onSwitch;
  final VoidCallback onAdd;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 50 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      color: hasBackground ? FlutterTiktokPalette.back2 : Colors.transparent,
      child: Row(
        children: <Widget>[
          _tab(
            key: const Key('fluttertiktok_tab_home'),
            title: '首页',
            tab: FlutterTiktokTab.home,
          ),
          _tab(
            key: const Key('fluttertiktok_tab_follow'),
            title: '关注',
            tab: FlutterTiktokTab.follow,
          ),
          Expanded(
            child: GestureDetector(
              key: const Key('fluttertiktok_tab_add'),
              behavior: HitTestBehavior.opaque,
              onTap: onAdd,
              child: const Center(
                child: Icon(
                  Icons.add_box,
                  size: 32,
                  color: FlutterTiktokPalette.white,
                ),
              ),
            ),
          ),
          _tab(
            key: const Key('fluttertiktok_tab_msg'),
            title: '消息',
            tab: FlutterTiktokTab.msg,
          ),
          _tab(
            key: const Key('fluttertiktok_tab_me'),
            title: '我',
            tab: FlutterTiktokTab.me,
          ),
        ],
      ),
    );
  }

  Widget _tab({
    required Key key,
    required String title,
    required FlutterTiktokTab tab,
  }) {
    return Expanded(
      child: Center(
        child: FlutterTiktokSelectText(
          key: key,
          title: title,
          isSelect: current == tab,
          onTap: () => onSwitch(tab),
        ),
      ),
    );
  }
}
