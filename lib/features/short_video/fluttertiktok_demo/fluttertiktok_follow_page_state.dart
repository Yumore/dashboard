import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_comment_sheet.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_follow_row.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_switch_app_bar.dart';
import 'package:flutter/material.dart';

class FlutterTiktokFollowPageState extends State<FlutterTiktokFollowPage> {
  /// Mirrors the source's `Map<int, bool> fMap`.
  final Map<int, bool> favorites = <int, bool>{};
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlutterTiktokPalette.back1,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          FlutterTiktokSwitchAppBar(
            index: selectedTab,
            labels: const <String>['推荐', '关注'],
            onSwitch: (int index) => setState(() => selectedTab = index),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: 80 + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: FlutterTiktokFollowPage.itemCount,
              itemBuilder: (BuildContext context, int index) {
                final bool isFavorite = favorites[index] ?? false;
                return FlutterTiktokFollowRow(
                  index: index,
                  isFavorite: isFavorite,
                  onFavorite: () =>
                      setState(() => favorites[index] = !isFavorite),
                  onComment: () => FlutterTiktokCommentSheet.show(context),
                  onShare: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
