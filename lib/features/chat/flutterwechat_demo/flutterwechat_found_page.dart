import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_wechat_item.dart';
import 'package:flutter/material.dart';

/// Port of the source discover tab (source `lib/found/found.dart`).
///
/// Every row is a source row; none of them opened a page in the source, so all
/// taps stay inert.
class FlutterWechatFoundPage extends StatelessWidget {
  const FlutterWechatFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      body: ListView(
        children: <Widget>[
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverMoments,
                title: '朋友圈',
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverScan,
                title: '扫一扫',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverShake,
                title: '摇一摇',
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverTopStories,
                title: '看一看',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverSearch,
                title: '搜一搜',
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverNearby,
                title: '附近的人',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverBottle,
                title: '漂流瓶',
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverShopping,
                title: '购物',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverGames,
                title: '游戏',
              ),
            ],
          ),
          _group(
            top: 20.0,
            bottom: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.discoverMiniPrograms,
                title: '小程序',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _group({
    required double top,
    double bottom = 0.0,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(top: top, bottom: bottom),
      color: Colors.white,
      child: Column(children: children),
    );
  }
}

/// The source divider between rows of the same group: 0.5 high, inset 15.
const Widget _divider = Padding(
  padding: EdgeInsets.only(left: 15.0, right: 15.0),
  child: Divider(height: 0.5, color: FlutterWechatPalette.divider),
);
