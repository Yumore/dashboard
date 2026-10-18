import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_message.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_remote_image.dart';
import 'package:flutter/material.dart';

/// Formats a time the way the source's `date_format` call did: `HH:mm:ss`.
String flutterWechatTimeLabel(DateTime time) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:'
      '${twoDigits(time.second)}';
}

/// Port of the source conversation row (source `lib/home/MessageItem.dart`).
///
/// The source's tap only showed a native toast, so the port keeps the row
/// inert; there is no chat thread in the source to open.
class FlutterWechatMessageItem extends StatelessWidget {
  const FlutterWechatMessageItem({required this.message, super.key});

  final FlutterWechatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5, color: FlutterWechatPalette.divider),
        ),
      ),
      child: FlutterWechatPressable(
        onPressed: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 13.0, right: 13.0),
              child: FlutterWechatRemoteImage(
                url: message.avatar,
                width: 48.0,
                height: 48.0,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.title,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: FlutterWechatPalette.primaryText,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8.0)),
                  Text(
                    message.subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: FlutterWechatPalette.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: AlignmentDirectional.topStart,
              margin: const EdgeInsets.only(right: 12.0, top: 12.0),
              child: Text(
                flutterWechatTimeLabel(message.time),
                style: const TextStyle(
                  fontSize: 14.0,
                  color: FlutterWechatPalette.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
