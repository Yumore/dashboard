import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_palette.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_pressable.dart';
import 'package:flutter/material.dart';

/// Port of the bordered catalogue card in the source Flutter UI grid (source
/// `lib/widgets/FlutterUI.dart`, its private `ItemWidget`).
class FlutterWechatCatalogCard extends StatelessWidget {
  const FlutterWechatCatalogCard({
    required this.title,
    required this.describe,
    this.target,
    super.key,
  });

  final String title;
  final String describe;

  /// Source `routeName`: only 基础组件 and Material Components had one.
  final WidgetBuilder? target;

  @override
  Widget build(BuildContext context) {
    return FlutterWechatPressable(
      onPressed: () {
        final target = this.target;
        if (target == null) {
          return;
        }
        Navigator.of(context).push(MaterialPageRoute<void>(builder: target));
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1.0,
              color: FlutterWechatPalette.catalogBorder,
            ),
            left: BorderSide(
              width: 1.0,
              color: FlutterWechatPalette.catalogBorder,
            ),
            right: BorderSide(
              width: 1.0,
              color: FlutterWechatPalette.catalogBorder,
            ),
            bottom: BorderSide(
              width: 1.0,
              color: FlutterWechatPalette.catalogBorder,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                describe,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
