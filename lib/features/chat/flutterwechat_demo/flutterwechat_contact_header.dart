import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact_item.dart';
import 'package:flutter/material.dart';

/// Port of the source contacts header (source
/// `lib/contacts/ContactHeader.dart`): 新的朋友, 群聊, 公众号.
class FlutterWechatContactHeader extends StatelessWidget {
  const FlutterWechatContactHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        FlutterWechatContactItem(
          titleName: '新的朋友',
          imageName: FlutterWechatAvailableImages.contactAddFriend,
        ),
        FlutterWechatContactItem(
          titleName: '群聊',
          imageName: FlutterWechatAvailableImages.contactGroupChat,
        ),
        FlutterWechatContactItem(
          titleName: '公众号',
          imageName: FlutterWechatAvailableImages.contactPublicAccount,
        ),
      ],
    );
  }
}
