import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_demo_config.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_palette.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_detail_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_profile_page.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_remote_image.dart';
import 'package:dashboard/features/short_video/fluttertiktok_demo/fluttertiktok_top_tool_row.dart';
import 'package:flutter/material.dart';

class FlutterTiktokProfilePageState extends State<FlutterTiktokProfilePage> {
  static const List<String> videoTabLabels = <String>['作品', '关注', '喜欢'];

  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FlutterTiktokProfileDetailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.orange, Colors.red],
            ),
          ),
        ),
        Positioned.fill(
          top: 400,
          child: const ColoredBox(color: FlutterTiktokPalette.back1),
        ),
        ListView(
          key: const Key('fluttertiktok_profile_scroll'),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(height: 20 + topInset),
            SizedBox(
              height: 130,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 18,
                    bottom: 12,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: FlutterTiktokPalette.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: FlutterTiktokPalette.white),
                      ),
                      child: ClipOval(
                        child: FlutterTiktokRemoteImage(
                          key: const Key('fluttertiktok_profile_avatar'),
                          url: FlutterTiktokDemoConfig.avatarUrl,
                          width: 74,
                          height: 74,
                        ),
                      ),
                    ),
                  ),
                  Positioned(right: 8, bottom: 52, child: _actionButton()),
                ],
              ),
            ),
            Container(
              color: FlutterTiktokPalette.back1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      FlutterTiktokDemoConfig.profileHandle,
                      style: FlutterTiktokPalette.big,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      FlutterTiktokDemoConfig.profileBio,
                      style: FlutterTiktokPalette.smallWithOpacity,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        for (final String tag
                            in FlutterTiktokDemoConfig.profileTags)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: FlutterTiktokPalette.white.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: FlutterTiktokPalette.smallWithOpacity,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        _stat(
                          FlutterTiktokDemoConfig.profileFollowing,
                          FlutterTiktokDemoConfig.profileFollowingLabel,
                        ),
                        _stat(
                          FlutterTiktokDemoConfig.profileFollowers,
                          FlutterTiktokDemoConfig.profileFollowersLabel,
                        ),
                        _stat(
                          FlutterTiktokDemoConfig.profileLikes,
                          FlutterTiktokDemoConfig.profileLikesLabel,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: FlutterTiktokPalette.white.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _videoTable(),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: topInset + 20,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 62,
            child: FlutterTiktokTopToolRow(
              canPop: widget.canPop,
              onPop: widget.onPop,
              backKey: FlutterTiktokProfilePage.backKey,
              right: GestureDetector(
                key: FlutterTiktokProfilePage.moreKey,
                behavior: HitTestBehavior.opaque,
                onTap: _openDetail,
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0x5C000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    size: 24,
                    color: FlutterTiktokPalette.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton() {
    return GestureDetector(
      key: FlutterTiktokProfilePage.actionKey,
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: FlutterTiktokPalette.orange),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.isSelfPage
              ? FlutterTiktokDemoConfig.profileWallet
              : FlutterTiktokDemoConfig.profileFollow,
          style: FlutterTiktokPalette.normal.copyWith(
            color: FlutterTiktokPalette.orange,
          ),
        ),
      ),
    );
  }

  Widget _stat(String title, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title, style: FlutterTiktokPalette.big),
          const SizedBox(width: 4),
          Text(tag, style: FlutterTiktokPalette.smallWithOpacity),
        ],
      ),
    );
  }

  Widget _videoTable() {
    return Container(
      color: FlutterTiktokPalette.back1,
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < videoTabLabels.length; i++) _videoTab(i),
            ],
          ),
          const SizedBox(height: 8),
          for (
            int row = 0;
            row < FlutterTiktokDemoConfig.profileVideoTileRows;
            row++
          )
            Row(
              children: <Widget>[
                for (
                  int column = 0;
                  column < FlutterTiktokDemoConfig.profileVideoTilesPerRow;
                  column++
                )
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        key: Key(
                          'fluttertiktok_profile_tile_'
                          '${row * FlutterTiktokDemoConfig.profileVideoTilesPerRow + column}',
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: FlutterTiktokPalette.darkGray,
                          border: Border.all(color: FlutterTiktokPalette.black),
                        ),
                        child: Text(
                          '作品',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: FlutterTiktokPalette.white.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _videoTab(int index) {
    final bool selected = index == 0;
    return GestureDetector(
      key: Key('fluttertiktok_profile_tab_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: FlutterTiktokPalette.orange,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              videoTabLabels[index],
              style: selected
                  ? FlutterTiktokPalette.big
                  : FlutterTiktokPalette.bigWithOpacity,
            ),
          ],
        ),
      ),
    );
  }
}
