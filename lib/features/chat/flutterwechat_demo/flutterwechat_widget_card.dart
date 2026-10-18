import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_local_image.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_remote_image.dart';
import 'package:flutter/material.dart';

/// Port of the source `ItemWidget` card (source `lib/widgets/WidgetsItem.dart`).
///
/// The source cards in `basicsData`/`materialData` never set `routeName`, so
/// their taps print a message and do nothing else; the port keeps them inert.
class FlutterWechatWidgetCard extends StatelessWidget {
  const FlutterWechatWidgetCard({
    required this.title,
    required this.describe,
    this.imagePath,
    this.imageUrl,
    super.key,
  });

  final String title;
  final String describe;
  final String? imagePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(5.0),
      child: FlutterWechatPressable(
        onPressed: () {},
        child: Container(
          width: MediaQuery.of(context).size.width / 2 - 20,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 100.0,
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: imagePath != null
                    ? FlutterWechatLocalImage(imagePath!)
                    : FlutterWechatRemoteImage(url: imageUrl ?? ''),
              ),
              Text(
                title,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                describe,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
