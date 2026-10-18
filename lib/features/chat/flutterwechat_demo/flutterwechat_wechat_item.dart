import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_catalog_page.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_local_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:flutter/material.dart';

/// Port of the source `WechatItem` row (source `lib/common/wechatItem.dart`).
///
/// Rows with no host destination keep the source's inert tap (the source
/// showed a native toast, which this host port does not have). `钱包` is the one
/// row with a real destination in the source, so it opens the ported Flutter UI
/// catalogue.
class FlutterWechatWechatItem extends StatelessWidget {
  const FlutterWechatWechatItem({
    required this.title,
    this.imagePath,
    this.icon,
    super.key,
  });

  final String title;
  final String? imagePath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FlutterWechatPressable(
      onPressed: () {
        if (title == '钱包') {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const FlutterWechatCatalogPage(),
            ),
          );
        }
      },
      child: SizedBox(
        height: 50.0,
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 22.0, right: 20.0),
              child: imagePath != null
                  ? FlutterWechatLocalImage(
                      imagePath!,
                      width: 32.0,
                      height: 32.0,
                    )
                  : SizedBox(height: 32.0, width: 32.0, child: Icon(icon)),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
                color: FlutterWechatPalette.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
