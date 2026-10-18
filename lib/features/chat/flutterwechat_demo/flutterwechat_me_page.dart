import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_config.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_local_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_remote_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_wechat_item.dart';
import 'package:flutter/material.dart';

/// Port of the source profile tab (source `lib/me/me.dart`).
class FlutterWechatMePage extends StatelessWidget {
  const FlutterWechatMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterWechatPalette.scaffold,
      body: ListView(
        children: <Widget>[
          Container(
            height: 80.0,
            margin: const EdgeInsets.only(top: 20.0),
            color: Colors.white,
            child: FlutterWechatPressable(
              onPressed: () {},
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 12.0, right: 15.0),
                    child: FlutterWechatRemoteImage(
                      url: FlutterWechatDemoConfig.profileAvatarUrl,
                      width: 70.0,
                      height: 70.0,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text(
                          FlutterWechatDemoConfig.profileName,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: FlutterWechatPalette.primaryText,
                          ),
                        ),
                        Text(
                          FlutterWechatDemoConfig.profileWechatId,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: FlutterWechatPalette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 20.0),
                    child: FlutterWechatLocalImage(
                      FlutterWechatAvailableImages.meArrow,
                      width: 24.0,
                      height: 24.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                title: '钱包',
                imagePath: FlutterWechatAvailableImages.meWallet,
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.meFavorites,
                title: '收藏',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.meAlbum,
                title: '相册',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.meCards,
                title: '卡包',
              ),
              _divider,
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.meStickers,
                title: '表情',
              ),
            ],
          ),
          _group(
            top: 20.0,
            children: const <Widget>[
              FlutterWechatWechatItem(
                imagePath: FlutterWechatAvailableImages.meSettings,
                title: '设置',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _group({required double top, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(top: top),
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
