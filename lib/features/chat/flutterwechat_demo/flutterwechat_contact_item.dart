import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_contact.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_demo_config.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_local_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_remote_image.dart';
import 'package:flutter/material.dart';

/// Port of the source contact row (source `lib/contacts/ContactItem.dart`).
///
/// The source uses this same row for two jobs: a real [item], or a fixed
/// [titleName] with a bundled [imageName] (the three header rows). Both are
/// preserved.
class FlutterWechatContactItem extends StatelessWidget {
  const FlutterWechatContactItem({
    this.item,
    this.titleName,
    this.imageName,
    super.key,
  });

  final FlutterWechatContact? item;
  final String? titleName;
  final String? imageName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5, color: FlutterWechatPalette.divider),
        ),
      ),
      child: FlutterWechatPressable(
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (imageName != null)
                FlutterWechatLocalImage(imageName!, width: 36.0, height: 36.0)
              else
                FlutterWechatRemoteImage(
                  url: item != null && item!.avatarUrl != ''
                      ? item!.avatarUrl
                      : FlutterWechatDemoConfig.contactFallbackAvatarUrl,
                  width: 36.0,
                  height: 36.0,
                ),
              Container(
                margin: const EdgeInsets.only(left: 12.0),
                child: Text(
                  titleName ?? item?.name ?? '暂无',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: FlutterWechatPalette.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
